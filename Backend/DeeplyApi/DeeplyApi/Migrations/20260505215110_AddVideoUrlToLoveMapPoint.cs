using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DeeplyApi.Migrations
{
    /// <inheritdoc />
    public partial class AddVideoUrlToLoveMapPoint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "VideoUrl",
                table: "LoveMapPoints",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "VideoUrl",   
                table: "LoveMapPoints");
        }
    }
}
