<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>

  <xsl:template match="rss">
    <html>
    <body>
   <xsl:apply-templates select ="channel/item" />
    </body>
    </html>
</xsl:template>
  <xsl:template match="item">
    <table border ="1">
      <tr><td>
        <a >
          <xsl:attribute name="href" >
            <xsl:value-of select="link"/>
          </xsl:attribute>
        <xsl:value-of select="title"/>
         </a>
      </td></tr>
      <tr><td>
        <xsl:apply-templates select="description" />
      </td></tr>
    </table>
  </xsl:template>
  <xsl:template match="description">
  
      <xsl:text  select="." disable-output-escaping="yes"/>
  
  </xsl:template>


</xsl:stylesheet> 
