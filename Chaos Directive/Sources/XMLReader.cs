using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace ChaosDirective
{
    abstract class XMLReader
    {

        protected int i;
        protected uint ui;
        protected short s;
        protected ushort us;
        protected long l;
        protected ulong ul;
        protected double d;
        protected float f;
        protected byte by;
        protected sbyte sby;
        protected bool b;


        #region XML Getters

        /// <summary>
        /// Returns an XmlElement with the specified tag and offset.
        /// </summary>
        /// <param name="xD">XmlDocument to search for the specified element.</param>
        /// <param name="str">String containing the name of the element.</param>
        /// <param name="offset">Int identifying which Element to return, default = 0.</param>
        public XmlElement GetElement(XmlDocument xD, string str, int offset = 0)
        {
            return (XmlElement) xD.GetElementsByTagName(str)[offset];
        }

        /// <summary>
        /// Returns an XmlElement with the specified tag and offset.
        /// </summary>
        /// <param name="xE">XmlElement to search for the specified sub-element.</param>
        /// <param name="str">String containing the name of the sub-element.</param>
        /// <param name="offset">Int identifying which element to return, default = 0.</param>
        public XmlElement GetElement(XmlElement xE, string str, int offset = 0)
        {
            return (XmlElement)xE.GetElementsByTagName(str)[offset];
        }

        /// <summary>
        /// Returns a string containing the value of the specified tag and offset.
        /// </summary>
        /// <param name="xD">XmlDocument to search for the specified element.</param>
        /// <param name="str">String containing the name of the element.</param>
        /// <param name="offset">Int identifying which Element to return, default = 0.</param>
        public string GetValue(XmlDocument xD, string str, int offset = 0)
        {
            return xD.GetElementsByTagName(str)[offset].InnerText;
        }

        /// <summary>
        /// Returns a string containing the value of the specified tag and offset.
        /// </summary>
        /// <param name="xE">XmlElement to search for the specified sub-element.</param>
        /// <param name="str">String containing the name of the sub-element.</param>
        /// <param name="offset">Int identifying which element to return, default = 0.</param>
        public string GetValue(XmlElement xE, string str, int offset = 0)
        {
            return xE.GetElementsByTagName(str)[offset].InnerText;
        }

        #endregion

        #region Parsing Overloads

        /// <summary>
        /// Parses an int out of a string.
        /// </summary>
        /// <param name="i32">The int which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public int Parse(out int i32, string str)
        {

            int.TryParse(str, out i32);
            return i32;
        }

        /// <summary>
        /// Parses a uint out of a string.
        /// </summary>
        /// <param name="ui32">The uint which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public uint Parse(out uint ui32, string str)
        {
            uint.TryParse(str, out ui32);
            return ui32;
        }

        /// <summary>
        /// Parses a short out of a string.
        /// </summary>
        /// <param name="i16">The short which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public short Parse(out short i16, string str)
        {
            short.TryParse(str, out i16);
            return i16;
        }

        /// <summary>
        /// Parses a ushort out of a string.
        /// </summary>
        /// <param name="ui16">The ushort which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public ushort Parse(out ushort ui16, string str)
        {
            ushort.TryParse(str, out ui16);
            return ui16;
        }

        /// <summary>
        /// Parses a long out of a string.
        /// </summary>
        /// <param name="i64">The long which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public long Parse(out long i64, string str)
        {
            long.TryParse(str, out i64);
            return i64;
        }

        /// <summary>
        /// Parses a ulong out of a string.
        /// </summary>
        /// <param name="ui64">The ulong which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public ulong Parse(out ulong ui64, string str)
        {
            ulong.TryParse(str, out ui64);
            return ui64;
        }

        /// <summary>
        /// Parses a double out of a string.
        /// </summary>
        /// <param name="d">The double which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public double Parse(out double d, string str)
        {
            double.TryParse(str, out d);
            return d;
        }

        /// <summary>
        /// Parses a float out of a string.
        /// </summary>
        /// <param name="f">The float which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public float Parse(out float f, string str)
        {
            float.TryParse(str, out f);
            return f;
        }

        /// <summary>
        /// Parses a byte out of a string.
        /// </summary>
        /// <param name="by">The byte which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public byte Parse(out byte by, string str)
        {
            byte.TryParse(str, out by);
            return by;
        }

        /// <summary>
        /// Parses an sbyte out of a string.
        /// </summary>
        /// <param name="sby">The sbyte which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public sbyte Parse(out sbyte sby, string str)
        {
            sbyte.TryParse(str, out sby);
            return sby;
        }

        /// <summary>
        /// Parses a bool out of a string. If the string is a number n, returns true if n == 1.
        /// </summary>
        /// <param name="b">The bool which will be initialized & returned.</param>
        /// <param name="str">The string to parse.</param>
        public bool Parse(out bool b, string str)
        {
            if (!bool.TryParse(str, out b))
            {
                int i = 0;
                if (int.TryParse(str, out i)) { return b = (i == 1) ? true : false; }
            }
            return b;
        }

        #endregion
    }
}
