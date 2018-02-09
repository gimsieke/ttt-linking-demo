<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ttt="http://transpect.io/tokenized-to-tree"
  xmlns:dbk="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs ttt dbk"
  version="2.0">

  <xsl:import href="http://transpect.io/tokenized-to-tree/xsl/re-insert-placeholders.xsl"/>  

  <xsl:template match="@xml:lang" mode="in-patched"/>

  <xsl:template match="/" mode="#default">
    <xsl:text>&#xa;</xsl:text>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="ttt:token[not(@role = 'quote')]" mode="in-patched">
    <link xmlns="http://docbook.org/ns/docbook">
      <xsl:apply-templates select="@linkend, node()" mode="#current"/>
    </link>  
  </xsl:template>
  
</xsl:stylesheet>