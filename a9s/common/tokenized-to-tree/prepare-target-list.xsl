<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ttt="http://transpect.io/tokenized-to-tree"
  xmlns:ppp="http://transpect.io/postprocess-poppler"
  xmlns:dav="http://www.dav-medien.de/meta"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs ttt ppp dbk xlink"
  version="2.0">
  
  <xsl:import href="http://transpect.io/tokenized-to-tree/postprocess-poppler-module/xsl/reusable-functions.xsl"/>

  <xsl:template match="* | @*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <titles xmlns="http://docbook.org/ns/docbook">
      <xsl:apply-templates select="//chapter/title" mode="#current">
        <xsl:sort select="string-length(.)" order="descending"/>
      </xsl:apply-templates>
    </titles>
  </xsl:template>
  
  <xsl:template match="chapter[@xml:id]/title">
    <xsl:copy>
      <xsl:variable name="regex-components" as="xs:string+">
        <xsl:choose>
          <xsl:when test="matches(., '^[\d.]+$')">
            <!-- In strings that contain, for ex., 'Tab. 5.1.4-2', 
              avoid matching only '1.4' and linking it to 'eab_numtext-1.04.00.00'.
            Also, at the end of a sentence, do match 1.4. --> 
            <xsl:sequence select="'(^|[\s\p{Zs}\p{P}-[.\[]])('"/>
            <xsl:sequence select="ppp:regexify(.)"/>
            <xsl:sequence select="')(\.?[\s\p{Zs}\p{P}-[-.\]]]|$)'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="'(^|[\s\p{Zs}\p{P}-[\p{Pd}]])('"/>
            <xsl:sequence select="ppp:regexify(.)"/>
            <xsl:sequence select="')([\s\p{Zs}\p{P}-[\p{Pd}]]|$)'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="regex" select="string-join($regex-components, '')"/>
      <xsl:attribute name="linkend" select="string(../@xml:id)"/>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="ppp:regexify">
    <xsl:param name="input" as="xs:string"/>
    <xsl:value-of select="replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                      $input,
                                      '([.?*+\{\}\[\]\(\)])', 
                                      '\\$1'
                                    ),
                                    '-',
                                    '[-&#xad;&#x2010;&#x2011;]'
                                  ),
                                  '−',
                                  '[−–]'
                                ),
                                '([&#x2012;-&#x2015;])',
                                '&#x2008;?$1&#x2008;?'
                              ),
                              '&#x2019;',
                              '[&#x2019;'']'
                            ),
                            '[\s\p{Zs}]+',
                            ' '
                          )"/>
  </xsl:function>

</xsl:stylesheet>