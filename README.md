# Level Up!
3D "Top Down" browser game with level editor, written in Haxe.

## Try it now - in progress...
http://flashplusplus.net/haxe/levelup/index.html

## Screenshot(s)
Ingame
![image](https://user-images.githubusercontent.com/13141660/80431506-e5ac6d80-88f1-11ea-8a47-8f10b47400e2.png)
![image](https://user-images.githubusercontent.com/13141660/70577922-89e48080-1bac-11ea-9b10-8f8183ee4ca3.png)

Editor
![image](https://user-images.githubusercontent.com/13141660/72680806-66232d00-3abe-11ea-8fc9-c322a524a330.png)
![image](https://user-images.githubusercontent.com/13141660/70577969-b00a2080-1bac-11ea-9702-de1203783941.png)
![image](https://user-images.githubusercontent.com/13141660/70577990-c1532d00-1bac-11ea-96a5-d91d6f23c0ce.png)

## TODO - general
- Fix for some render issues like some unit has a black "shadow"
- Add missing Human, Orc, Elf, Undead characters
- Team based colorization
- Fix z-index render problem when the camera distance is to big
- Fix "shadow-jump" bug during Day/Night change
- etc...

## TODO - Game
- Height map based pathfinding
- Implement Fog of war
- Area damage
- Html based hero ui
- Life and mana bar into the game
- Add team system
- Implement a Moba custom game
- etc...

## TODO - Adventure editor
- Add missing preview images (Is it possible to generate it like the heightmap?)
- Script editor
- Weather editor
- Camera editor
- Unit editor
- Team editor
- Pathfinding editor
- Define map sizes
- Possibility to change the cam view angle
- Fix asset selection - there is a problem with colliders
- etc...

## TODO - Terrain editor
- Possibility to change the layer order
- Undo / Redo functionality
- Fix paint bug when the position is locked - after mouse up

## TODO - HeightMap editor
- Undo / Redo functionality

## TODO - Day and Night settings
- Possibility to set the exact duration of a day like 1 day is 5 mins
- Add ambient color which multiply the current color with the selected one
- Undo / Redo functionality

## TODO - Region editor
- Possibility to delete region with button in the list + with delete key
- Fix jumping dragging
- Add resize logic
- Add possibility to rename the region
- Add possibility to change the region order
- Add mouse over effect
- Camera focus to the region after selecting it on the list
- Undo / Redo functionality


## Dependencies
- **Haxe 4.0.0** Haxe is an open source toolkit based on a modern high level strictly typed programming language https://haxe.org/
- **Heaps 1.7.0** A mature cross platform graphics engine designed for high performance games. https://heaps.io/
- **javascript-astar 1.4.1** Pathfinder js lib. http://github.com/bgrins/javascript-astar
- **LZString** Powerful String compressor https://pieroxy.net/blog/pages/lz-string/index.html https://github.com/markknol/hx-lzstring
- **Tink libraries** Check build.hxml for details https://lib.haxe.org/t/tink/
- **Coconut libraries** Check build.hxml for details https://lib.haxe.org/t/coconut/
- **HPP Package** Some useful classes for haxe projects https://github.com/NewKrok/HPP-Package

Our webpage:
http://flashplusplus.net

Our Facebook page:
https://www.facebook.com/flashplusplus/
