/* DROP ALL TABLES */
DROP TABLE dbo.Comments_Analysis;
GO
DROP TABLE dbo.Comments;
GO
DROP TABLE dbo.Returns;
GO
DROP TABLE dbo.Products;
GO

/* CREATE TABLES */
CREATE TABLE dbo.Comments (
	Id int PRIMARY KEY,
	Timestamp datetime NOT NULL DEFAULT (getdate()),
	CommentText nvarchar(4000) NOT NULL,
	Name nvarchar(100) NOT NULL
);
GO

CREATE TABLE dbo.Comments_Analysis (
	Id int PRIMARY KEY,
	Sentiment int NULL DEFAULT (NULL),
	Language nvarchar(100) NULL DEFAULT (NULL),
	EnglishTranslation nvarchar(4000) NULL,
	Keywords nvarchar(1000) NULL DEFAULT (NULL)
);

ALTER TABLE dbo.Comments_Analysis ADD CONSTRAINT FK__Comments__Id FOREIGN KEY (Id) REFERENCES Comments (Id);
GO

CREATE TABLE dbo.Returns (
	Id int PRIMARY KEY,
  CustomerId int NOT NULL,
	OrderNumber nvarchar(10) NOT NULL,
	ReturnImageUrl nvarchar(1000) NULL,
	ReturnNotes nvarchar(MAX) NULL,
);
GO

CREATE TABLE Products (
  Id int PRIMARY KEY,
  Sku nvarchar(255) NOT NULL,
  Name nvarchar(255) NOT NULL,
  Price decimal(10,2) DEFAULT 0 NOT NULL,
  Description nvarchar(max),
  ImageUrl nvarchar(1000),
  Tags nvarchar(255),
  AverageSentiment int,
  AutoTagConfidence int
);
GO

/* INSERT SEED DATA */

/* Comments */
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (1, 'The best hammer I''ve ever bought. Definitely worth the money.', 'Bob');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (2, 'Your website search function is terrible.', 'Henry');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (3, 'You lost the details of my product return and refuse to replace it!', 'Alice');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (4, 'Why don''t you list the products you have in stock?', 'Simon');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (5, 'Ich liebe deine Website, sie ist wunderschön.', 'Felicity');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (6, 'Der Eimer, den du mir verkauft hast war schrecklich. Er hat ein loch.', 'Christian');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (7, 'Ich musste die Handschuhe zurückgeben, die ich gekauft hatte. Der Austausch hat lange gedauert.', 'Liesel');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (8, 'Je veux remplacer mon téléviseur car il est défectueux. Mais on me dit que la garantie a expiré.', 'Laurent');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (9, '¡El mejor destornillador eléctrico que he usado en mi vida!', 'Enrique');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (10, 'Este martillo está etiquetado como un juguete.', 'Clara');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (11, 'El único almacén que provee clavos de madera.', 'Juan');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (12, N'Suicaを店頭で使うことはできますか。', 'Yoshido');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (13, N'両刃を売っていますか。', 'Madoka');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (14, N'我不喜欢这把螺丝刀。', 'Henry');
INSERT INTO dbo.Comments (Id, CommentText, Name) VALUES (15, N'这是我最喜欢的商店。 我每周都去看看。', 'Lu');

/* Returns */
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (1, 2232, 'O18LSM', 'https://lp3s3img.blob.core.windows.net/returnimages/return-1.png');
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (2, 5216, '4FIZ11', NULL);
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (3, 2571, 'JJBT2N', NULL);
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (4, 3672, 'L6ARY3', 'https://lp3s3img.blob.core.windows.net/returnimages/return-4.jpg');
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (5, 981, 'XF9QG4', NULL);
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (6, 8366, 'MUIUB7', 'https://lp3s3img.blob.core.windows.net/returnimages/return-6.jpg');
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (7, 10021, 'Y14SBU', 'https://lp3s3img.blob.core.windows.net/returnimages/return-7.jpg');
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (8, 7621, 'CDYJFR', NULL);
INSERT INTO dbo.Returns (Id, CustomerId, OrderNumber, ReturnImageUrl) VALUES (9, 6622, '2NVWAZ', NULL);

/* Products */
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (1,'4QJ2SI','Brushes Made from Weird Stuff','https://tailwindtraders.azureedge.net/images/art_supplies/brushes_made_from_stuff.jpg',25.99, 'Most paint brushes are made form synthetic this and that making brush strokes look the same everywhere! Why not try our Brushes Made from Weird Stuff? We have turtle shell, dry grass and cat whisker brushes. See the difference!','brush', 80);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (2,'2UF27O','The Right Tool for the Job: Lockable Wrench', 'https://tailwindtraders.azureedge.net/products/500/2090.jpg',38.99, 'Our Lockable Wrench is a great fit for any jobs that need an extra hand. It can clasp securely, then lock on and not let go while you go about your business.','clasp', 41);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (3,'8LNJRB','Amazing-zing-zingy Bug Zapper','https://tailwindtraders.azureedge.net/images/gardening_outdoors/amazing_bugzappers.jpg',49.99,'We love nature, but when it bothers, stings or bites us, it needs to die. Our Amazing-zing-zingy Bug Zapper is quick and humane, eliminating those pests with a satisfying ZZZZZZAP!','bug-zapper', 90);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (4,'YWRH6A','Sweeping Statement Broom','https://tailwindtraders.azureedge.net/images/gardening_outdoors/brooms.jpg',35.99, 'Catch all the dust and dirt in your home or garage with our Sweeping Statement Broom Set.','broom', 69);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (5,'OOJ6JS','Green with Ivy Pruning Set','https://tailwindtraders.azureedge.net/images/gardening_outdoors/gloves_and_shears.png',18.99, 'Our Green with Ivy shears cut through any vine or small branch with ease. Our canvas gloves will protect your green thumb as well!','shears,gloves', 90);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (6,'B55ITU','The Right Tool for the Job: Nail Bender', 'https://tailwindtraders.azureedge.net/images/tools/the_right_tool.jpg',23.99, 'Nobody likes a straight nail, and with our professional Nail Bender, boring hunks of wood can become a thing of the past. Able to support any angle of nail bend required, this handy device has you covered.','bender', 17);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (7,'NPMZWA','Bespoke, Retro Holiday Lighting','https://tailwindtraders.azureedge.net/images/holidays_and_gifts/holiday_lights.jpg',36.99, 'Blinking lights and animated figures are fun, but nothing beats the nostalgic lighting from decades ago. Our Bespoke, Retro Holiday Lighting pack will let your neighbors know that you care for tradition.','lighting', 88);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (8,'2KHZYZ','Powered by Hand LED Light','https://tailwindtraders.azureedge.net/images/holidays_and_gifts/led_handpowered_light.jpg',16.99, 'The latest advancements in science, literally at your fingertips! Using the natural galvanic response created by the heat of your hand and the salts in your sweat, *you* will power the Powered by Hand LED light.','lighting', 94);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (9,'EKCI9I','The Overkill Series: Nut Cracker','https://tailwindtraders.azureedge.net/images/holidays_and_gifts/overkill_nut_cracker.jpg',69.99, 'Nut crackers take far too much effort and can hurt your hands. With our Overkill Nut Cracker, you can crush that nut with one single blow while working off a little stress.','nut', 24);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (10,'MWQSZB','Bespoke, Vintage Word Processing Application','https://tailwindtraders.azureedge.net/images/holidays_and_gifts/typewriter.jpg',89.99, 'Writing your thoughts and ideas using a modern word processing application can indeed be productive, but what does it say about you and your particular style? Our Bespoke Word Processing Application lets you show others how tasteful you are, in your own bespoke way.','typewriter', 82);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (11,'LA8QWB','Boingo''s Rubber Mallet', 'https://tailwindtraders.azureedge.net/products/500/2126.jpg',23.99, 'Built specifically for gently smashing things, this friendly rubber mallet has been tested to 10,000 impacts. Note: not a toy.','toy', 12);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (12,'5NOOLS','The Decider','https://tailwindtraders.azureedge.net/images/holidays_and_gifts/youbethejudge_decision_maker.jpg',79.99, 'As a parent, you need to be sure your decisions are heard loud and clear. As a professional, it''s important for your thoughts to carry weight in a meeting. As a person, it''s time for others to pay attention! The You Be The Judge Decision Maker puts a firm exclamation point to any concept you''re trying to get across.','gavel', 51);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (13,'TACG84','Lead Balloon 55-pound Anvil','https://tailwindtraders.azureedge.net/images/metal_working/55-pound-anvil.jpg',69.99, 'Our Lead Balloon 55-pound Anvil is the perfect base to use for your next smithing project. Made from solid iron ore, our anvil can be used for shaping fake weaponry for your next LARP event, or as a clever ruse to capture a fast bird.','anvil', 71);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (14,'9DZTZS','Northern Light Arc Welder','https://tailwindtraders.azureedge.net/images/metal_working/arc_welder.jpg',499.99, 'Bond different pieces of metal into any shape you can think of with our Northern Light Arc Welder. Channeling 100 volts of pure electricity into slabs of metal has never been more fun.','welder', 96);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (15,'UND7IM','Ball-peen Hammer', 'https://tailwindtraders.azureedge.net/products/500/2100.jpg',20.99, 'Made of titanium, this ball-peen hammer will flatten or unflatten metal sheets of various thicknesses.','ball', 31);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (16,'DUDKRS','Bare Knuckles Hand Grinder','https://tailwindtraders.azureedge.net/images/metal_working/hand_grinder.jpg',49.99, 'Whether sharpening the blades of your skates or polishing your favorite cuirass for this weekend''s LARP event - our Bare Knuckle Hand Grinder is up to the task. Sharpen edges and polish things like a medieval boss.','grinder', 71);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (17,'NAY9K6','No-neck Hammer', 'https://tailwindtraders.azureedge.net/products/500/2085.jpg',22.99, 'Need a good hammer but only have limited space in your toolkit? The No-neck Hammer is for you. It measures just 3 inches long, but is still capable of delivering a punch.','no-neck', 32);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (18,'GRV7RW','Bare Knuckles Hand Sander','https://tailwindtraders.azureedge.net/images/tools/hand_sander.jpg',32.99, 'For quick and easy sanding jobs there''s nothing better than Tailwind''s Bare Knuckle Hand Sander. Powered by a 12-volt motor and a dust bag, you''ll have those maple boards smooth and shiny in no time.','sander', 66);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (19,'2P5GXP','The Right Tool for the Job: Plane Old Planer','https://tailwindtraders.azureedge.net/images/tools/planer.jpg',49.99, 'Strip away the grime and nasty bits from that old wood stock using our Plain Old Planer. Power planers are much too precise for bespoke work like yours, so do it by hand the way they did a century ago.','planer', 96);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (20,'2CE156','The Right Tool for the Job: Power Leveller','https://tailwindtraders.azureedge.net/images/tools/power_leveller.jpg',26.99, 'Take your picture-hanging skills to the next level with the Power Leveller from Tailwind Traders. With our unique ''fit the bubble in the thing'' levelling mechanism, a true level is virtually assured.','level', 69);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (21,'XFGOYM','Pre-randomized Bolt Set','https://tailwindtraders.azureedge.net/images/tools/random_bolts.jpg',23.99, 'Every house has a drawer full of random bits and bobs. For the do-it-yourselfers out there, these are often various screws and bolts. Is your random drawer empty? If so, fill it with our Pre-randomized Bolt Set and start loudly sifting through it, looking for that metric-sized bolt that you _know_ isn''t in there.','bolt,screw', 73);
INSERT INTO Products (Id, Sku, Name, ImageUrl, Price, Description, Tags, AverageSentiment) VALUES (22,'N8X9JE','The Right Tool for the Job: Organized Wrench Set','https://tailwindtraders.azureedge.net/images/tools/wrench_set.jpg',68.99, 'Tighten those bolts into oblivion with our Organized Wrench Set, which comes presorted so you don''t have to think about where each wrench goes.','wrench', 68);