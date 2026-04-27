using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class WeeklyCheckIn
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    public int UserId { get; set; }
    public DateOnly WeekStart { get; set; }
    [MaxLength(2000)] public string WhatWasGreat { get; set; } = string.Empty;
    [MaxLength(2000)] public string WhereWasTension { get; set; } = string.Empty;
    [MaxLength(2000)] public string WhatToImprove { get; set; } = string.Empty;
}
