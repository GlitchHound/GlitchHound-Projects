using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace ChaosDirective
{
    class TilesetListReader : XMLReader
    {
        public TilesetListReader(string filename)
        {
            XmlDocument xd = new XmlDocument();
            xd.Load(filename);
            XmlNodeList xnl = xd.GetElementsByTagName("Tileset");
            TilesetReader tr = null;
            foreach (XmlNode node in xnl)
            {
                ProcessTileset(node, tr);
            }
            tr = null;
            xd = null;
        }

        #region Processing Methods

        public void ProcessTileset(XmlNode xnNode, TilesetReader tr)
        {
            XmlElement xe = (XmlElement)xnNode;
            string setName = ProcessSetName(xe.GetElementsByTagName("setName")[0]);
            string filename = ProcessFilename(xe.GetElementsByTagName("filename")[0]);
            tr = new TilesetReader(filename, setName);
        }

        public string ProcessSetName(XmlNode xnNode)
        {
            return xnNode.InnerText;
        }

        public string ProcessFilename(XmlNode xnNode)
        {
            return xnNode.InnerText;
        }

        #endregion

    }
}
