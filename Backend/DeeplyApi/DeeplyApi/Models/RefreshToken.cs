using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class RefreshToken
{
    [Key] public int Id { get; set; }
    public int UserId { get; set; }
    [MaxLength(256)] public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public bool IsRevoked { get; set; }
}
