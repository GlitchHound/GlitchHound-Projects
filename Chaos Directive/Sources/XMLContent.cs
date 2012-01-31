using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.Graphics;

namespace ChaosDirective
{
    static class XMLContent
    {
        public static List<Tileset> tilesets = new List<Tileset>();
        public static ContentManager cm;
        public static SpriteBatch sb;

        public static void Initialize(ContentManager content, SpriteBatch batch)
        {
            cm = content;
            sb = batch;
        }
    }
}
