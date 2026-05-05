using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class LoveMapPoint
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    [MaxLength(500)] public string? PhotoUrl { get; set; }
    [MaxLength(500)] public string? VideoUrl { get; set; }
    [MaxLength(1000)] public string? Description { get; set; }
    [MaxLength(500)] public string? Address { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
