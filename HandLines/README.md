# HandLines

Control the hands by issuing commands in a line. You can flatten the balls by 
issuing an interact sub-command on top of one with an empty hand. You can shape 
the flattenned ball into a rectangle by issuing an interact subcommand on top 
of one with a hand holding a knife.

### Controls
- Click to issue a `move` subcommand
- W or up-arrow to issue a `pick up` subcommand
- S or down-arrow to issue a `put down` subcommand
- SPACE or right-arrow to issue an `interract` subcommand
- Right-Click to finalize a command

### The Idea
This is a mechanic I would use in a strategy crafting game. The idea was 
inspired by thinking about how a cooking game similar to OverCooked or Plate Up 
could be implemented for mobile. Instead of a direct character controller I 
opted for system of issuing commmands which reduces the reliance on fine motor 
skills and shifts the focus to strategizing. The command system can be used for 
something other than cooking though.

