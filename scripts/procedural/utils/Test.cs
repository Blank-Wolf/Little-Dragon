using System.Linq;
using Godot;
using Godot.Collections;
using Littledragon.scripts.procedural.controllers;
using Littledragon.scripts.procedural.generators;

namespace Littledragon.scripts.procedural.utils;

public partial class Test : Node2D
{
    [Export] private int _width, _height, _seed = 0;
    [Export] private Array<RoomBuilder> _rooms;
    [Export] private Dictionary<int, int> _connections = new();

    public override void _Ready()
    {
        GD.Print($"w: {_width}, h:{_height}, seed:{_seed}");
        Generate();
    }

    private void Generate()
    {
        GD.Print("LD - LOG - GRID - STARTING GENERATION!\nLD - LOG - GRID - Creating Grid...");
        var (grid, dots) = GridFactory.CreateGrid(_width, _height, _rooms.ToArray(), _seed);
        GD.Print("LD - LOG - GRID - Grid Created! Starting Collections");
        GD.Print(grid);

        foreach (var dot in _connections)
        {
            try
            {
                GridFactory.Connect(grid, dots[dot.Key], dots[dot.Value]);
                GD.Print($"LD - LOG - GRID - connection: {dot.Key} {dot.Value}");
            }
            catch
            {
                GD.Print("LD - ERROR - GRID - Connection Failed! Maybe out of index?");
                GD.Print("LD - ERROR - GRID - Generation Script Stopped! Exit: 1");
                return;
            }
        }

        GD.Print("LD - LOG - GRID - Initialized Successfully! printing");
        GD.Print(grid.ToString());

        GD.Print("LD - LOG - GRID - Instantiating Rooms");
        var rooms = ChunkManager.InstantiateGrid(this, grid);
        GD.Print("LD - LOG - GRID - All Rooms instances are ready. Preparing to launch");

        foreach (var chunk in rooms)
        {
            chunk.GetOwner<Node2D>().Visible = false;
            chunk.GetOwner<Node2D>().Position = new Vector2I(1000000, 1000000);
        }

        rooms[0].GetOwner<Node2D>().Position = Vector2.Zero;
        rooms[0].GetOwner<Node2D>().Visible = true;
        rooms[0].ActiveNeighbors();

        GD.Print("LD - LOG - GRID - All Done!");
    }
}
