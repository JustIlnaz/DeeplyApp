namespace DeeplyApi.Requests;

public class CreateTodoRequest
{
    public string Title { get; set; } = string.Empty;
    public int? ResponsibleUserId { get; set; }
}
