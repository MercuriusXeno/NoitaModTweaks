CHANGES
=======
Adds "wand growth" feature to the wand workshop (2.0):
  If your wand is already better than the sacrificed wand on a given stat pillar, it absorbs a % of the stat instead of replacing it.
  If your wand is worse than the wand on the pillar (even a little), it does what it originally does and replaces the stat.
  If you use this and for whatever reason don't want the behavior, setting mix_ratio to 100 or less disables the feature.
Adds "omni" pillar feature:
  Omni only works if the mix_ratio is above 100%.
  Omni will *only* absorb stats. Whatever your absorb ratio is (mix_ratio - 100), Omni takes half.
  In exchange, Omni works on all absorbable stats simultaneously (that's 6 pillars at once).

INSTALLATION
============
    Read this carefully.
        I'm not responsible for your broken saves or botched changes.
            1. Back up your wand_workshop (2.0)mod in case you break something. 
            2. These changes can't do permanent damage to your game. If you get something wrong just redownload the mod.
            3. Maybe backup your saves, I'm not a lua dev. I may break stuff. Use at your own risk.
        
    Where to find the files we're replacing:
    
        1. Steam workshop users should find the mod in:
            [your-steam-library-folder]\steamapps\workshop\content\881100\3302329900\
            (881100 is Noita, 3302329900 is WandWorkshop2.0)
            
        2. If you installed WandWorkshop2.0 manually it should be in your Noita\mods folder in your steam library called something like:
            [your-steam-library-folder]\steamapps\common\Noita\mods\wand_workshop\
            (if yours is named something else, that's fine, I don't need to know. Use common sense.)
    
    How to replace the files:
        Move the files from the folder containing this readme directly into the wand_workshop mod folder (not the mods folder).
    
    There should be a handful of files overwritten ( ".." being the wand workshop mod folder)
        ..\settings.lua
        ..\files\entities\altar\altar.lua
        ..\files\biomes\temple_altar_left.lua
        ..\data\biome_impl\temple\altar_left.png
        ..\data\biome_impl\temple\altar_left_visual.png
      
    and two new files:
        ..\files\entities\altar\sacrificial_altars\omni_altar.png
        ..\files\entities\altar\sacrificial_altars\omni_altar.xml  

If it doesn't ask you to overwrite settings.lua and altar.lua, etc, you've done something wrong.
Restore your backup and try again, except instead of what you did, consider following the instructions.
That's all. 