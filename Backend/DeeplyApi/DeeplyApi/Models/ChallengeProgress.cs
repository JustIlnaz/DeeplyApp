    using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class ChallengeProgress
{
    [Key] public int Id { get; set; }
    public int CoupleChallengeId { get; set; }
    public DateOnly Day { get; set; }
    public bool Done { get; set; }
}
