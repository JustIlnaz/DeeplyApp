using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class CoupleChallenge
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    public int TemplateId { get; set; }
    public DateOnly StartedOn { get; set; }
    public bool IsCompleted { get; set; }
}
