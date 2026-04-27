using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class TimeCapsule
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(5000)] public string Letter { get; set; } = string.Empty;
    public DateTime OpenAtUtc { get; set; }
}
