using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class ChallengeTemplate
{
    [Key] public int Id { get; set; }
    [MaxLength(200)] public string Title { get; set; } = string.Empty;
    public int DurationDays { get; set; }
}
