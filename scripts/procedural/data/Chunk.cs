using System.Linq;
using Godot;
using Littledragon.scripts.procedural.controllers;

namespace Littledragon.scripts.procedural.data;

/// <summary>
/// Represents a room in the game, which can have up to four neighboring rooms.
/// </summary>
public partial class Chunk : Node2D
{
    /// <summary>
    /// References to the doors or pathways leading to adjacent rooms.
    /// </summary>
    private Node2D _left, _up, _right, _down;

    /// <summary>
    /// Stores references to neighboring Room instances.
    /// </summary>
    private Chunk[] _neighborRooms = new Chunk[4];

    public Chunk[] NeighborRooms => _neighborRooms;

    private Area2D _area2D;
    
    /// <summary>
    /// Assigns a neighboring room in a specific direction.
    /// </summary>
    /// <param name="io">Direction index (0: Left, 1: Up, 2: Right, 3: Down).</param>
    /// <param name="chunk">The room to set as a neighbor.</param>
    public void SetNeighbor(int io, Chunk chunk)
    {
        _neighborRooms[io] = chunk;
    }

    public void DesActiveNeighbors()
    {
        foreach (var neigh in _neighborRooms.Where(_neighborRooms => _neighborRooms != ChunkManager.CurrentChunk))
        {
            try
            {
                neigh.GetOwner<Node2D>().Visible = false;
                neigh.GetOwner<Node2D>().Position = new Vector2(1000000, 100000000);
             }
            catch { /* ignored */ }
        }
    }

    public void ActiveNeighbors()
    {
        for (var i = 0; i <= 3; i++)
        {
            try { Active(i); } catch { /* ignored */ }
        }
        return;

        void Active(int i)
        {
            var neighborChunk = _neighborRooms[i];
            var neighborRoot = neighborChunk.GetOwner<Node2D>();
            neighborRoot.Visible = true;

            var distance = i switch
            {
                0 => _left.GlobalPosition - neighborChunk._right.GlobalPosition,
                1 => _down.GlobalPosition - neighborChunk._up.GlobalPosition,
                2 => _right.GlobalPosition - neighborChunk._left.GlobalPosition,
                3 => _up.GlobalPosition - neighborChunk._down.GlobalPosition,
                _ => Vector2.Zero
            };

            neighborRoot.GlobalPosition += distance;
        }
    }

    /// <summary>
    /// Binary representation of the room's open sides.
    /// </summary>
    private int RoomInputs { get; set; }

    /// <summary>
    /// Called when the node enters the scene tree. Initializes room connections.
    /// </summary>
    public override void _Ready()
    {
        // get exits (case exist)
        _left = GetNodeOrNull<Node2D>("left");
        _up = GetNodeOrNull<Node2D>("up");
        _right = GetNodeOrNull<Node2D>("right");
        _down = GetNodeOrNull<Node2D>("down");

        // set binary chunk value
        if (_left != null) RoomInputs |= 0b1000;
        if (_up != null) RoomInputs |= 0b0100;
        if (_right != null) RoomInputs |= 0b0010;
        if (_down != null) RoomInputs |= 0b0001;

        // connect ObBodyEntered from Area2D
        _area2D = Owner.GetNode<Area2D>("Area2D");
        _area2D.BodyEntered += OnBodyEntered;
        _area2D.BodyExited += OnBodyExited;
    }

    private void OnBodyEntered(Node2D body)
    {
        if (!body.IsInGroup("player")) return;
        ActiveNeighbors();
        ChunkManager.CurrentChunk = this;
    }
    private void OnBodyExited(Node2D body)
    {
        if (!body.IsInGroup("player") && ChunkManager.CurrentChunk != this) return;
        DesActiveNeighbors();
    }
    
    /// <summary>
    /// Returns a binary string representation of the room's connections.
    /// </summary>
    /// <returns>A 4-bit string indicating open paths (Left-Up-Right-Down).</returns>
    public override string ToString()
    {
        return $"{(_left != null ? "1" : "0")}{(_up != null ? "1" : "0")}" +
               $"{(_right != null ? "1" : "0")}{(_down != null ? "1" : "0")}";
    }

    public int ToInt()
    {
        return RoomInputs;
    }
}
