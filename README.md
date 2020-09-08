# Level Up!
3D "Top Down" browser game with level editor, written in Haxe.

## Try it now - in progress...
http://flashplusplus.net/haxe/levelup/index.html

## Screenshot(s)
Main Menu
![image](https://user-images.githubusercontent.com/13141660/83974895-dfe27880-a8f0-11ea-9235-962b7dd252c9.png)
![image](https://user-images.githubusercontent.com/13141660/83974906-ecff6780-a8f0-11ea-9668-0428758937db.png)

Ingame
![image](https://user-images.githubusercontent.com/13141660/80431506-e5ac6d80-88f1-11ea-8a47-8f10b47400e2.png)
![image](https://user-images.githubusercontent.com/13141660/70577922-89e48080-1bac-11ea-9b10-8f8183ee4ca3.png)

Editor
![image](https://user-images.githubusercontent.com/13141660/72680806-66232d00-3abe-11ea-8fc9-c322a524a330.png)
![image](https://user-images.githubusercontent.com/13141660/83974918-06a0af00-a8f1-11ea-9121-163b3835c016.png)

## TODO - general
- Create q0/q2 textures for terrains
- Create q0/q2 textures for neutral units
- Create q0/q2different quality textures for skyboxes
- Fix for some render issues like some unit has a black "shadow"
- Import missing Undead units
- Import missing Neutral units
- Import missing environments
- Fix "shadow-jump" bug during Day/Night change
- Create custom select form component
- etc...

## TODO - Settings
- Add shadow quality settings

## TODO - Game
- Height map based pathfinding
- Implement Fog of war
- Area damage
- Html based hero ui
- Add team system
- Implement a Moba custom game
- Fix asset selection - there is a problem with colliders
- Add group selection possibility
- etc...

## TODO - Adventure editor
- Add group selection possibility
- Add missing preview images
- Unit editor
- Team editor
- Define map sizes
- Fix asset selection - there is a problem with colliders
- etc...

## TODO - World settings
- Possibility to set the exact duration of a day like 1 day is 5 mins

## TODO - Terrain editor
- Possibility to change the layer order
- Undo / Redo functionality
- Fix paint bug when the position is locked - after mouse up

## TODO - Camera editor
- Create cam preview 3d object
- Undo / Redo functionality

## TODO - HeightMap editor
- Fix decrease height logic
- Undo / Redo functionality

## TODO - Light settings
- Possibility to configure shadow
- Undo / Redo functionality

## TODO - Region editor
- Possibility to delete region with button in the list + with delete key
- Fix jumping dragging
- Add resize logic
- Add possibility to rename the region
- Add possibility to change the region order
- Move regions from EditorModel to RegionModule
- Add mouse over effect
- Camera focus to the region after selecting it on the list
- Undo / Redo functionality

## TODO - Script editor
- Currently it's just a viewer, let's make it to dynamic
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
