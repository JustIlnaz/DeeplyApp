using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class CoupleTodo
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(300)] public string Title { get; set; } = string.Empty;
    public int? ResponsibleUserId { get; set; }
    [MaxLength(30)] public string Status { get; set; } = "todo";
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
