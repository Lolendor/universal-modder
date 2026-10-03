using Terraria.ModLoader;

namespace ModArsenal
{
	/// <summary>
	/// Mod Arsenal: weapons, enemies and a boss that aren't in vanilla Terraria, with bundled sprites processed
	/// locally (../assets/make_art.sh). tModLoader finds every ModItem / ModNPC / ModProjectile /
	/// ModSystem / ModCommand in the assembly by itself, so this class stays empty.
	///
	///   Weapons.cs        Homing Missile Launcher, Tactical Nuke
	///   EnergyWeapons.cs  Tesla Rifle, Singularity Launcher, Orbital Strike
	///   Mobs.cs           Scrap Drone, Neon Slime, Mech Walker
	///   Boss.cs           Drone Mothership (+ its rockets)
	///   Fx.cs             explosions, nuke crater + mushroom cloud, flash, camera focus
	///   Commands.cs       /arsenal, /mothership
	/// </summary>
	public class ModArsenal : Mod
	{
	}
}
