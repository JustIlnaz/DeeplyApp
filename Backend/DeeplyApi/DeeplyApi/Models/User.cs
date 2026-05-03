using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DeeplyApi.Models;

public class User
{
    [Key] public int Id { get; set; }
    [MaxLength(200)] public string Email { get; set; } = string.Empty;
    [MaxLength(200)] public string PasswordHash { get; set; } = string.Empty;
    [MaxLength(100)] public string Name { get; set; } = string.Empty;
    public int? GenderId { get; set; }
    public Gender? Gender { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? LastOnlineUtc { get; set; }
    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = [];
}
