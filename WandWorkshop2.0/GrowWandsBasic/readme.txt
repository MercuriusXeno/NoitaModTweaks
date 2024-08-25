WandGrowth (Basic) Add-on for WandWorkshop2.0 
    (Absorb Stats Only)

CHANGES
=======
Adds "wand growth" feature to the wand workshop (2.0):
  If your wand is already better than the sacrificed wand on a given stat pillar, it absorbs a % of the stat instead of replacing it.
  If your wand is worse than the wand on the pillar (even a little), it does what it originally does and replaces the stat.
  If you use this and for whatever reason don't want the behavior, setting mix_ratio to 100 or less disables the feature.

INSTALLATION
============
    Read this carefully. I'm not responsible for your broken saves or botched changes.
        1. Back up your saves, in case I break stuff.
        2. Back up your wand_workshop (2.0) mod in case YOU break something. 

To be clear, this is a mod of a mod. We're replacing some of the files in the mod folder with these.
    Where to find the files we're replacing:    
        1. Steam workshop users should find the mod in:
            [your-steam-library-folder]\steamapps\workshop\content\881100\3302329900\            
            
        2. If you installed WandWorkshop2.0 manually it should be in your Noita\mods folder in your steam library called something like:
            [your-steam-library-folder]\steamapps\common\Noita\mods\wand_workshop\            
    
    How to replace the files:
        Move the files from the folder containing this readme directly into the wand_workshop mod folder (not the mods folder).
    
    There should be two files overwritten ( ".." being the wand workshop mod folder)
        ..\settings.lua
        ..\files\entities\altar\altar.lua

If it doesn't ask you to overwrite settings.lua and altar.lua, you've done something wrong.
