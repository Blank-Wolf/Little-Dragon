using Godot;

namespace Littledragon.scripts.procedural.generators;

/// <summary>
/// Defines a blueprint for creating rooms within a specific area of the grid.
/// </summary>
[GlobalClass]
public partial class RoomBuilder : Resource
{
    [Export] private Vector2I _min, _max;
    [Export] private string _roomName;

    /// <summary>
    /// The minimum boundary of the room's position.
    /// </summary>
    public Vector2I Min
    {
        get => _min;
        private set => _min = value;
    }

    /// <summary>
    /// The maximum boundary of the room's position.
    /// </summary>
    public Vector2I Max
    {
        get => _max;
        private set => _max = value;
    }

    /// <summary>
    /// The identifier or name of the room.
    /// </summary>
    public string Name 
    {
        get => _roomName;
        private set => _roomName = value;
    }
    
    public RoomBuilder()
    {
        Min = _min;
        Max = _max;
        Name = _roomName;
    }
    
    /// <summary>
    /// Initializes a room builder with a specified rectangular area.
    /// </summary>
    /// <param name="name">The name or type of the room.</param>
    /// <param name="minX">The minimum X-coordinate of the room.</param>
    /// <param name="maxX">The maximum X-coordinate of the room.</param>
    /// <param name="minY">The minimum Y-coordinate of the room.</param>
    /// <param name="maxY">The maximum Y-coordinate of the room.</param>
    public RoomBuilder(string name, int minX, int maxX, int minY, int maxY)
    {
        Min = new Vector2I(minX, minY);
        Max = new Vector2I(maxX, maxY);
        Name = name;
    }

    /// <summary>
    /// Initializes a room builder for a single tile (1x1 room).
    /// </summary>
    /// <param name="name">The name or type of the room.</param>
    /// <param name="x">The X-coordinate of the room.</param>
    /// <param name="y">The Y-coordinate of the room.</param>
    public RoomBuilder(string name, int x, int y)
    {
        Min = new Vector2I(x, y);
        Max = new Vector2I(x, y);
        Name = name;
    }

}