using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using Microsoft.Xna.Framework;

namespace ChaosDirective
{
    class TilesetReader : XMLReader
    {
        public TilesetReader(string filename, string setName)
        {
            XmlDocument xd = new XmlDocument();
            xd.Load(filename);
            XmlNode xn = xd.GetElementsByTagName("Tileset")[0];
            ProcessTileset(xn, setName);
            xd = null;
        }

        #region Processing Methods

        public void ProcessTileset(XmlNode xnNode, string setName)
        {
            XmlElement xe = (XmlElement)xnNode;
            Tileset ts = new Tileset();
            ts.Name = setName;
            ProcessFilename(ts, xe.GetElementsByTagName("filename")[0]);
            ProcessTileSize(ts, xe.GetElementsByTagName("tileSize")[0]);
            ProcessBackground(ts, xe.GetElementsByTagName("Background")[0]);
            XmlNodeList xnl = xe.GetElementsByTagName("Tile");
            foreach (XmlNode node in xnl)
            {
                ProcessTile(ts, node);
            }
            XMLContent.tilesets.Add(ts);
        }

        public void ProcessBackground(Tileset ts, XmlNode xnNode)
        {
            XmlElement xe = (XmlElement)xnNode;
            List<BGLayer> bglList = new List<BGLayer>(10);
            ProcessBGFilename(ts, xe.GetElementsByTagName("bgFilename")[0]);
            XmlNodeList xnl = xe.GetElementsByTagName("layer");
            foreach (XmlNode node in xnl)
            {
                bglList.Add(ProcessLayer(node));
            }
            ts.LayerList = bglList;
        }

        public BGLayer ProcessLayer(XmlNode xnNode)
        {
            XmlElement xe = (XmlElement)xnNode;
            BGLayer bgl = new BGLayer();
            ProcessLayerNumber(bgl, xe.GetElementsByTagName("layerNumber")[0]);
            ProcessStartPos(bgl, xe.GetElementsByTagName("startPos")[0]);
            ProcessWidth(bgl, xe.GetElementsByTagName("width")[0]);
            ProcessHeight(bgl, xe.GetElementsByTagName("height")[0]);
            ProcessSpeedMod(bgl, xe.GetElementsByTagName("speedmod")[0]);
            return bgl;
        }

        public void ProcessTile(Tileset ts, XmlNode xnNode)
        {
            XmlElement xe = (XmlElement)xnNode;
            Tile t = new Tile();
            XmlNodeList xnl = xe.GetElementsByTagName("animated");
            if (!(xnl.Count < 1))
            {
                ProcessAnimated(t, xnl[0]);
            }
            ProcessRowNumber(t, xe.GetElementsByTagName("rowNumber")[0]);
            xnl = xe.GetElementsByTagName("rotation");
            if (!(xnl.Count < 1)) ProcessRotation(t, xnl[0]); 
            xnl = xe.GetElementsByTagName("flipVertically");
            if (!(xnl.Count < 1)) ProcessVerticalFlip(t, xnl[0]);
            xnl = xe.GetElementsByTagName("flipHorizontally");
            if (!(xnl.Count < 1)) ProcessHorizontalFlip(t, xnl[0]);
            xnl = xe.GetElementsByTagName("alternatives");
            if (!(xnl.Count < 1)) ProcessAlternatives(t, xnl[0]);
            byte ind = ProcessConnection(xe.GetElementsByTagName("connection")[0]);
            ts.dictTiles.Add(ind, t);
        }

        /// <summary>
        /// Processes a StartPos node for its values and returns a Point.
        /// </summary>
        /// <param name="xnNode">A StartPos node to evaluate.</param>
        public void ProcessStartPos(BGLayer bgl, XmlNode xnNode)
        {
            XmlElement xe = (XmlElement)xnNode;
            Point p = new Point(0, 0);
            ProcessXPos(p, xe.GetElementsByTagName("xPos")[0]);
            ProcessYPos(p, xe.GetElementsByTagName("yPos")[0]);
            bgl.Position = p;
        }

        public void ProcessXPos(Point p, XmlNode xnNode)
        {
            p.X = Parse(out i, xnNode.InnerText);
        }

        public void ProcessYPos(Point p, XmlNode xnNode)
        {
            p.Y = Parse(out i, xnNode.InnerText);
        }

        public void ProcessLayerNumber(BGLayer bgl, XmlNode xnNode)
        {
            bgl.LayerNumber = Parse(out i, xnNode.InnerText);
        }

        public void ProcessWidth(BGLayer bgl, XmlNode xnNode)
        {
            bgl.Width = Parse(out i, xnNode.InnerText);
        }

        public void ProcessHeight(BGLayer bgl, XmlNode xnNode)
        {
            bgl.Height = Parse(out i, xnNode.InnerText);
        }

        public void ProcessSpeedMod(BGLayer bgl, XmlNode xnNode)
        {
            bgl.RelativeSpeed = Parse(out i, xnNode.InnerText);
        }

        public void ProcessBGFilename(Tileset ts, XmlNode xnNode)
        {
            ts.BGFile = xnNode.InnerText;
        }

        public void ProcessFilename(Tileset ts, XmlNode xnNode)
        {
            ts.File = xnNode.InnerText;
        }

        public void ProcessTileSize(Tileset ts, XmlNode xnNode)
        {
            ts.TileSize = Parse(out i, xnNode.InnerText);
        }

        public void ProcessAnimated(Tile t, XmlNode xnNode)
        {
            XmlElement xe = (XmlElement)xnNode;
            XmlNodeList xnl;
            t.FrameCount = ProcessFrameCount(xe.GetElementsByTagName("frameCount")[0]);
            xnl = xe.GetElementsByTagName("frameRate");
            if (!(xnl.Count < 1))
            {
                t.FrameRate = ProcessFrameRate(xnl[0]);
            }
        }

        public byte ProcessFrameCount(XmlNode xnNode)
        {
            return Parse(out by, xnNode.InnerText);
        }

        public byte ProcessFrameRate(XmlNode xnNode)
        {
            return Parse(out by, xnNode.InnerText);
        }

        public void ProcessRowNumber(Tile t, XmlNode xnNode)
        {
            t.RowNumber = Parse(out by, xnNode.InnerText);
        }

        public void ProcessRotation(Tile t, XmlNode xnNode)
        {
            t.Rotation = Parse(out i, xnNode.InnerText);
        }

        public void ProcessVerticalFlip(Tile t, XmlNode xnNode)
        {
            t.FlipVertically = Parse(out b, xnNode.InnerText);
        }

        public void ProcessHorizontalFlip(Tile t, XmlNode xnNode)
        {
            t.FlipHorizontally = Parse(out b, xnNode.InnerText);
        }

        /// <summary>
        /// Processes a Connection node for its junctions and returns a tile index as a byte.
        /// For surface-squares, index is in the form of a two-digit number "XY" where X is the
        /// start of the closed surface and Y is the end, going counter-clockwise.
        /// </summary>
        /// <param name="xnNode">Connection node for processing.</param>
        public byte ProcessConnection(XmlNode xnNode)
        {
            byte tileIndex = 0, firstConn = 0, secondConn = 0;
            XmlElement xe = (XmlElement) xnNode;
            XmlNodeList xnl = xe.GetElementsByTagName("junction");
            XmlNode xn = xe.GetElementsByTagName("closedBetween")[0];
            if (xnl.Count == 2)
            {
                //Order connections from low to high.
                firstConn = Parse(out by, xnl[0].InnerText);
                if (Parse(out by, xnl[1].InnerText) > firstConn)
                {
                    //Second junction is higher than first junction.
                    secondConn = by;
                }
                else
                {
                    //Second junction is lower than first junction.
                    secondConn = firstConn;
                    firstConn = by;
                }

                //Set tileIndex based off closure. Higher weighted value is start of closed-off region.
                if (Parse(out by, xn.InnerText) == 1)
                {
                    //Closed counter-clockwise low to high.
                    tileIndex += (byte)(10 * firstConn);
                    tileIndex += secondConn;
                    return tileIndex;
                }
                else
                {
                    //Closed counter-clockwise high to low.
                    tileIndex += (byte)(10 * secondConn);
                    tileIndex += firstConn;
                    return tileIndex;
                }
            }
            else if (Parse(out by, xn.InnerText) == 1)
            {
                //Full square.
                tileIndex = 100;
            }
            else tileIndex = 200; //Empty square. "0" is reserved for a null-value.
            
            return tileIndex;
        }

        public void ProcessAlternatives(Tile t, XmlNode xnNode)
        {
           t.AlternateCount = Parse(out by, xnNode.InnerText);
        }

        #endregion

    }
}
