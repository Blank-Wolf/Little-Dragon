using System;
using Godot;

namespace Littledragon.scripts.procedural.data;

/// <summary>
/// Represents a room in the grid-based map, storing position, type, and connection data.
/// </summary>
public class Room
{
    /// <summary>
    /// A 4-bit binary string representation of the room's connections (Left-Up-Right-Down).
    /// </summary>
    public string Binary { get; private set; }

    /// <summary>
    /// Internal integer representation of the room's connections.
    /// </summary>
    private int _binary;

    /// <summary>
    /// The name or identifier of the room.
    /// </summary>
    public string Name { get; private set; }

    /// <summary>
    /// The grid position of this room.
    /// </summary>
    public readonly Vector2I Position;

    /// <summary>
    /// Indicates whether this room is a special predefined room.
    /// </summary>
    internal readonly bool SpecialRoom;

    /// <summary>
    /// Initializes a standard room with a position and an I/O (connection) value.
    /// </summary>
    /// <param name="position">Grid position of the room.</param>
    /// <param name="ios">Initial I/O value representing connections.</param>
    internal Room(Vector2I position, int ios)
    {
        Position = position;
        Name = ios.ToString();
        _binary = ios;
        Binary = Convert.ToString(_binary, 2).PadLeft(4, '0');
    }

    /// <summary>
    /// Initializes a special room with a custom name and I/O configuration.
    /// </summary>
    /// <param name="position">Grid position of the room.</param>
    /// <param name="ios">Initial I/O value representing connections.</param>
    /// <param name="name">Custom name for the special room.</param>
    internal Room(Vector2I position, int ios, string name)
    {
        SpecialRoom = true;
        Position = position;
        _binary = ios;
        Name = name;
    }

    /// <summary>
    /// Updates the room's I/O configuration and recalculates its binary representation.
    /// </summary>
    /// <param name="io">Bitmask representing the new connection direction.</param>
    internal void SetIo(int io)
    {
        _binary |= io;
        Name = !SpecialRoom ? (_binary & 0x0F).ToString() : Name;
        Binary = Convert.ToString(_binary, 2).PadLeft(4, '0');
    }

    public string GetTrueName() => (_binary & 0x0F).ToString();
}