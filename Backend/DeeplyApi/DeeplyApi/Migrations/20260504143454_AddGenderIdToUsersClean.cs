using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace DeeplyApi.Migrations
{
    public partial class AddGenderIdToUsersClean : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Genders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                            .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genders", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Genders_Name",
                table: "Genders",
                column: "Name",
                unique: true);

            migrationBuilder.Sql("INSERT INTO \"Genders\" (\"Name\") VALUES ('Male'), ('Female'), ('Other');");

            migrationBuilder.AddColumn<int>(
                name: "GenderId",
                table: "Users",
                type: "integer",
                nullable: true);

            migrationBuilder.Sql("UPDATE \"Users\" SET \"GenderId\" = (SELECT \"Id\" FROM \"Genders\" WHERE \"Name\" = 'Other')");

            migrationBuilder.CreateIndex(
                name: "IX_Users_GenderId",
                table: "Users",
                column: "GenderId");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Genders_GenderId",
                table: "Users",
                column: "GenderId",
                principalTable: "Genders",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastOnlineUtc",
                table: "Users",
                type: "timestamp with time zone",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Genders_GenderId",
                table: "Users");

            migrationBuilder.DropTable(
                name: "Genders");

            migrationBuilder.DropColumn(
                name: "LastOnlineUtc",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "GenderId",
                table: "Users");
        }
    }
}
