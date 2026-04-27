using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DeeplyApi.Models;

public class FinanceRecord
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(20)] public string Type { get; set; } = "expense";
    [MaxLength(80)] public string Category { get; set; } = "other";
    [Column(TypeName = "numeric(18,2)")] public decimal Amount { get; set; }
    public DateTime DateUtc { get; set; } = DateTime.UtcNow;
}
