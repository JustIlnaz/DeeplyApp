namespace DeeplyApi.Requests;

public class CreateFinanceGoalRequest
{
    public string Title { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
}
