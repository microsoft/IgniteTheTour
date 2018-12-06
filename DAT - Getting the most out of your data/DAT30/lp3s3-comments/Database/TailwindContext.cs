using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace lp3s3_comments.Database
{
    public class TailwindContext : DbContext
    {
        public TailwindContext(DbContextOptions<TailwindContext> options) : base(options)
        {
        }
        public static TailwindContext CreateNew(string connectionString)
        {
            var optionsBuilder = new DbContextOptionsBuilder<TailwindContext>();
            optionsBuilder.UseSqlServer(connectionString);
            var options = optionsBuilder.Options;
            return new TailwindContext(options);
        }

        public DbSet<Comment> Comments { get; set; }
        public DbSet<CommentAnalysis> CommentAnalyses { get; set; }
        public DbSet<Return> Returns { get; set; }
        public DbSet<Product> Products { get; set; }

    }

    public class Comment
    {
        [ForeignKey("Id")]
        public CommentAnalysis CommentAnalysis { get; set; }
        public int Id { get; set; }
        public DateTime TimeStamp { get; set; }
        public string CommentText { get; set; }
        public string Name { get; set; }
    }

    [Table("Comments_Analysis")]
    public class CommentAnalysis
    {
        public int Id { get; set; }
        public int? Sentiment { get; set; }
        public string Language { get; set; }
        public string EnglishTranslation { get; set; }
        public string Keywords { get; set; }
    }

    public class Return
    {
        public int Id { get; set; }
        public int CustomerId { get; set; }
        public string OrderNumber { get; set; }
        public string ReturnImageUrl { get; set; }
        public string ReturnNotes { get; set; }
    }

    public class Product
    {
        public int Id { get; set; }
        public string Sku { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
        public string Tags { get; set; }
        public int? AverageSentiment { get; set; }
        public int? AutoTagConfidence { get; set; }
    }
}