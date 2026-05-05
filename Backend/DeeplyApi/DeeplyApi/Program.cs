using DeeplyApi.Connection;
using DeeplyApi.Hubs;
using DeeplyApi.Interfaces;
using DeeplyApi.Models;
using DeeplyApi.Services;
using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.Converters.Add(new DateOnlyJsonConverter());
        options.JsonSerializerOptions.Converters.Add(new NullableDateOnlyJsonConverter());
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSignalR();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Postgres")));

builder.Services.AddHangfire(config =>
    config.UseSimpleAssemblyNameTypeSerializer()
        .UseRecommendedSerializerSettings()
        .UsePostgreSqlStorage(c => c.UseNpgsqlConnection(builder.Configuration.GetConnectionString("Postgres"))));
builder.Services.AddHangfireServer();

builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICoupleService, CoupleService>();
builder.Services.AddScoped<IChatService, ChatService>();
builder.Services.AddScoped<IFeatureService, FeatureService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Настройка статических файлов с явным путем
var staticFilesPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(staticFilesPath),
    RequestPath = ""
});
app.UseHangfireDashboard("/hangfire");
app.MapControllers();
app.MapHub<ChatHub>("/hubs/chat");

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
    
    // Создаем директории для загрузки файлов
    var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
    Directory.CreateDirectory(Path.Combine(uploadsPath, "memories"));
    Directory.CreateDirectory(Path.Combine(uploadsPath, "lovemap"));
    
    if (!db.ChallengeTemplates.Any())
    {
        db.ChallengeTemplates.AddRange(
            new ChallengeTemplate { Title = "7-day gratitude", DurationDays = 7 },
            new ChallengeTemplate { Title = "14-day support ritual", DurationDays = 14 },
            new ChallengeTemplate { Title = "30-day micro dates", DurationDays = 30 }
        );
        db.SaveChanges();
    }
}

app.Run();
