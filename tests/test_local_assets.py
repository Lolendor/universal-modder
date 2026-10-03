"""Exercise the preserved tools and the example asset workflow without service credentials."""
import os
from pathlib import Path
import socket
import subprocess
import sys
import urllib.request

import pytest
from PIL import Image

from um import cli


REPO = Path(__file__).resolve().parents[1]
ART_SCRIPT = REPO / "examples/terraria-tmodloader/assets/make_art.sh"


@pytest.mark.parametrize("group", ["scan", "sprite", "render3d", "video", "win", "backup", "publish", "kb"])
def test_cli_help_without_credentials_or_network(group, monkeypatch, capsys):
    for key in list(os.environ):
        if key.endswith(("_KEY", "_TOKEN", "_SECRET", "_KEY_FILE")):
            monkeypatch.delenv(key)

    def no_network(*args, **kwargs):
        pytest.fail("CLI help attempted a network request")

    monkeypatch.setattr(urllib.request, "urlopen", no_network)
    monkeypatch.setattr(socket, "create_connection", no_network)
    with pytest.raises(SystemExit) as result:
        cli.main([group, "--help"])
    assert result.value.code == 0
    assert f"usage: um {group}" in capsys.readouterr().out


def run_art(tmp_path, source=None):
    env = {key: value for key, value in os.environ.items()
           if not key.endswith(("_KEY", "_TOKEN", "_SECRET", "_KEY_FILE"))}
    env.update(UM_NO_UV="1", OUT=str(tmp_path / "sprites"), ICON=str(tmp_path / "icon.png"),
               PATH=str(Path(sys.executable).parent) + os.pathsep + env.get("PATH", ""))
    if source is not None:
        env["GEN"] = str(source)
    else:
        env.pop("GEN", None)
    return subprocess.run(["bash", str(ART_SCRIPT)], cwd=REPO, env=env,
                          capture_output=True, text=True, timeout=120)


def test_bundled_art_rebuilds_to_engine_frame_sizes(tmp_path):
    result = run_art(tmp_path)
    assert result.returncode == 0, result.stderr
    expected = {
        "HomingMissileLauncher": (64, 26), "HomingMissile": (38, 16),
        "TacticalNuke": (40, 84), "TeslaRifle": (62, 30),
        "SingularityLauncher": (70, 34), "OrbitalStrike": (24, 38),
        "ScrapDrone": (46, 60), "NeonSlime": (38, 68),
        "MechWalker": (40, 138), "DroneMothership": (240, 300),
    }
    for name, size in expected.items():
        with Image.open(tmp_path / "sprites" / f"{name}.png") as image:
            assert image.size == size
            assert image.mode == "RGBA"
            assert image.getchannel("A").getextrema() == (0, 255)
    with Image.open(tmp_path / "icon.png") as icon:
        assert icon.size == (80, 80)


def test_missing_art_stops_before_writing_sprites(tmp_path):
    result = run_art(tmp_path, source=tmp_path / "missing-source")
    assert result.returncode == 1
    assert "Missing local art" in result.stderr
    assert "missile_launcher" in result.stderr and "mothership" in result.stderr
    assert not (tmp_path / "sprites").exists()
    assert not (tmp_path / "icon.png").exists()
