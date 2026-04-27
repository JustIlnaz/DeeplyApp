namespace DeeplyApi.Requests;

public class CreateTimeCapsuleRequest
{
    public string Letter { get; set; } = string.Empty;
    public DateTime OpenAtUtc { get; set; }
}
