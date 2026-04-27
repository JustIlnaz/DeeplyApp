namespace DeeplyApi.Requests;

public class CreateSecretMessageRequest
{
    public string Message { get; set; } = string.Empty;
    public DateTime OpenAtUtc { get; set; }
}
