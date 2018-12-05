using System;
using System.Collections.Generic;
using System.Linq;

namespace lp3s3_comments.Database
{
    public class ExtendedComment
    {
        public int Id { get; set; }
        public DateTime TimeStamp { get; set; }
        public string CommentText { get; set; }
        public string Name { get; set; }
        public int? Sentiment { get; set; }
        public string Language { get; set; }
        public string EnglishTranslation { get; set; }
        public string Keywords { get; set; }

        public static IEnumerable<ExtendedComment> FromDb(IEnumerable<Comment> comments, IEnumerable<CommentAnalysis> commentAnalysis)
        {
            var result = comments.GroupJoin(commentAnalysis,
                    c => c.Id, ca => ca.Id,
                    (c, ca) => new { comment = c, extended = ca.DefaultIfEmpty() })
                .SelectMany(r => r.extended.Select(ec => new ExtendedComment
                {
                    Id = r.comment.Id,
                    TimeStamp = r.comment.TimeStamp,
                    CommentText = r.comment.CommentText,
                    Name = r.comment.Name,
                    Sentiment = ec?.Sentiment,
                    Language = ec?.Language,
                    EnglishTranslation = ec?.EnglishTranslation,
                    Keywords = ec?.Keywords
                }));

            return result;
        }
    }
}