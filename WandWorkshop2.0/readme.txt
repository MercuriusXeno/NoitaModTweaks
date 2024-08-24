Adds "wand growth" feature to the wand workshop:
  If your wand is already better than the sacrificed wand on a given stat pillar, it absorbs a % of the stat instead of replacing it.
  If your wand is worse than the wand on the pillar (even a little), it does what it originally does and replaces the stat.
  If you use this and for whatever reason don't want the behavior, setting mix_ratio to 100 or less disables the feature.

To "install" this, replace two files:
  1. [wand_workshop]/files/entities/altar/altar.lua
  2. [wand_workshop]/settings.lua

That's all. 
