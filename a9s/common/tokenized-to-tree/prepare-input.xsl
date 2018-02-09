<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ttt="http://transpect.io/tokenized-to-tree"
  xmlns:dbk="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs ttt"
  version="2.0">
  
  <xsl:import href="http://transpect.io/tokenized-to-tree/xsl/prepare-input-docbook.xsl"/>
  
<!--  <xsl:param name="prepare-for-full-text-search" as="xs:string" select="'true'"/>-->
  
  <xsl:template match="*[ttt:is-para-like(.)]/@xml:id" mode="ttt:discard">
    <xsl:next-match/>
    <xsl:attribute name="ttt:chapter-id" select="ancestor::dbk:chapter/@xml:id"/>
  </xsl:template>
  
  <xsl:function name="ttt:is-para-like" as="xs:boolean">
    <xsl:param name="element" as="element(*)"/>
    <xsl:choose>
      <xsl:when test="name($element) = ('para', 'simpara', 'caption')">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$element/self::title/parent::dbk:chapter">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$element/self::title">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>