namespace DeeplyApi.Requests;

public class CreateFinanceRecordRequest
{
    public string Type { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime DateUtc { get; set; }
}
