CHANGES
=======
Adds "wand growth" feature to the wand workshop (2.0):
  If the sacrifice wand for a stat pillar wouldn't improve the target wand by swapping stats, it has a % of its stats stolen instead.
  The % is based on the mix ratio. If you set it above 100%, anything above 100% is the stolen amount (so 110% => 100% swap + 10% theft if already better)
  If you set the mix ratio to 100 or less, growth is disabled for the stat pillars.
Adds "omni" pillar feature:
  Omni pillar works if the mix_ratio is above 100% or, alternatively, if you set the omni ratio to something other than 0%.
  Omni will *only* absorb stats that can be grown. Whatever your absorb ratio is (mix_ratio - 100), Omni takes half.
  In exchange, Omni works on all absorbable stats simultaneously (that's 6 pillars at once): speed, reload, mana, charge, slots and spread.

INSTALLATION
============
    Read this carefully. I'm not responsible for your broken saves or botched changes.
            1. Back up your saves, in case I break something.
            2. Back up your wand_workshop (2.0) mod in case YOU break something. 

To be clear: this is a mod of a mod (Wand Workshop 2.0). You're replacing some of the mod's files with these ones.
    Where to find the files we're replacing:    
        1. Steam workshop users should find the mod in:
            [your-steam-library-folder]\steamapps\workshop\content\881100\3302329900\
            
        2. If you installed WandWorkshop2.0 manually it should be in your Noita\mods folder in your steam library called something like:
            [your-steam-library-folder]\steamapps\common\Noita\mods\wand_workshop\            
    
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

If it doesn't ask you to overwrite files, you've done something wrong.
