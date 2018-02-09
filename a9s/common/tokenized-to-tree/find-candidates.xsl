<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ttt="http://transpect.io/tokenized-to-tree"
  xmlns:dbk="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs ttt dbk"
  version="2.0">
  
  <xsl:template match="node() | @*" mode="#default count eliminate-shorter-tokens merge quotes">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="normalized-reflist" as="document-node(element(dbk:titles))" select="collection()[2]"/>
  
  <xsl:key name="by-id" match="*[@xml:id]" use="@xml:id"/>
  
  <xsl:template match="ttt:para/*[@ttt:text]"><!-- as="element(ttt:tokens)*" -->
    <xsl:next-match/>
    <xsl:variable name="content" as="xs:string" select="@ttt:text"/>
    <xsl:variable name="own-id" as="xs:string?" select="@ttt:chapter-id"/>
    <xsl:variable name="count" as="element(ttt:tokens)*">
      <!-- For each match, a new ttt:tokens element will be created from text. The matching token is
        tagged as ttt:t within ttt:tokens. Each ttt:t token will get @start and @end attributes. 
        A token at the beginning of the ttt:tokens para has a @start position of 0.
        If it is one char long, its @end position is 1, as would be the @start position of an immediately
        following token -->
      <xsl:call-template name="tag-each-match-in-a-distinct-tokens-element">
        <xsl:with-param name="reflist-items"
          select="$normalized-reflist/dbk:titles/dbk:title"/>
        <xsl:with-param name="string" select="$content"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="only-for-other-modul-ids" as="element(ttt:tokens)*">
      <!-- We need to take these into account because: 
        Imagine both the text line and the reflist contain both terms,
        "Cinnarizin <i>CRS</i>" and "Cinnarizin".
        "Cinnarizin <i>CRS</i>" is restricted, by ID, to only
        become a link in a certain document (that is different from the current).
        Then the "Cinnarizin" in "Cinnarizin <i>CRS</i>" shouldn’t become a link,
        either. A standalone "Cinnarizin", however, should become a link.
        This variable will be used in determining which possible matches
        to consider when calculating whether a given string in the current
        document, such as "Cinnarizin", is contained in another string, such 
        as "Cinnarizin <i>CRS</i>", that would also match at the same location
        if it were allowed to match in the current document. 
        Yes, it’s complicated.
      --> 
      <xsl:call-template name="tag-each-match-in-a-distinct-tokens-element">
        <xsl:with-param name="reflist-items"
          select="$normalized-reflist/dbk:titles/dbk:title[not($own-id = @xml:id)]
                                                          [not(@regex = key('by-id', $own-id, $normalized-reflist)/@regex)]"/>
        <xsl:with-param name="string" select="$content"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="count($count) ge 1">
      <!-- We don’t do a distinct XSLT pass over the whole document. This makes debugging a bit harder.
      You can uncomment the following comment in order to write intermediate results into the 2_find_candidates.xml
      debugging document. -->
      <!--<xsl:sequence select="$count"/>
      <xsl:comment>##################
Eliminate:</xsl:comment>-->
      <xsl:variable name="eliminate" as="element(ttt:tokens)+">
        <!-- Eliminate tokens that are wholly covered by a longer token. 
        The total number of ttt:tokens elements remains the same, but some
        ttt:t elements with ttt:tokens will be dissolved. -->
        <xsl:for-each select="$count">
          <xsl:apply-templates select="." mode="eliminate-shorter-tokens">
            <xsl:with-param name="others" select="($count union $only-for-other-modul-ids) except ." tunnel="yes" as="element(ttt:tokens)*"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="remaining" as="element(ttt:tokens)*" select="$eliminate[ttt:t]"/>
      <xsl:if test="count($remaining) = 0">
        <xsl:message select="'No remaining tokens after eliminating shorter coverage duplicates: ', $count, '&#xa;  ', $eliminate, '&#xa;  ', base-uri(root())"></xsl:message>
      </xsl:if>
      <!-- uncomment for debugging info in 2_find_candidates.xml: -->
      <!--<xsl:sequence select="$remaining"/>
      <xsl:comment>##################
Merge:</xsl:comment>-->
      <xsl:variable name="merged" as="element(ttt:tokens)*">
        <xsl:choose>
          <xsl:when test="count($remaining) eq 1">
            <xsl:sequence select="$remaining"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$remaining[1]" mode="merge">
              <xsl:with-param name="others" tunnel="yes" select="$remaining[position() gt 1]"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="quotes" as="element(ttt:tokens)*">
        <xsl:apply-templates select="$merged" mode="quotes"/>
      </xsl:variable>
      <xsl:apply-templates select="$quotes" mode="count"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="tag-each-match-in-a-distinct-tokens-element" as="element(ttt:tokens)*">
    <xsl:param name="reflist-items" as="element(dbk:title)*"/>
    <xsl:param name="string" as="xs:string"/>
    <xsl:for-each select="$reflist-items">
      <xsl:variable name="tag" as="element(ttt:tokens)">
        <ttt:tokens>
          <xsl:variable name="reflist-title" select="." as="element(dbk:title)"/>
          <xsl:analyze-string select="$string" regex="{@regex}" flags="i">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <ttt:t>
                <xsl:copy-of select="$reflist-title/(@* except @regex)"/>
                <xsl:value-of select="regex-group(2)"/>
              </ttt:t>
              <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:value-of select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </ttt:tokens>
      </xsl:variable>
      <xsl:apply-templates select="$tag" mode="count"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="ttt:tokens[not(ttt:t)]" mode="count"/>
  
  <xsl:template match="ttt:t" mode="count">
    <xsl:copy>
      <xsl:call-template name="start-end"/>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="start-end">
    <xsl:variable name="start" select="string-length(string-join(preceding::text(), ''))" as="xs:integer"/>
    <xsl:attribute name="start" select="$start"/>
    <xsl:attribute name="end" select="$start + string-length(.)"/>
  </xsl:template>

  <xsl:template match="ttt:t" mode="eliminate-shorter-tokens">
    <xsl:param name="others" as="element(ttt:tokens)*" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="some $o in $others/ttt:t
                      satisfies (number($o/@start) &lt;= number(@start) and number($o/@end) >= number(@end))">
        <xsl:apply-templates mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="ttt:tokens" mode="merge">
    <xsl:param name="others" tunnel="yes" as="element(ttt:tokens)+"/>
    <xsl:variable name="sorted" as="element(ttt:t)+">
      <xsl:perform-sort select="(ttt:t, $others/ttt:t)">
        <xsl:sort select="@start" data-type="number"/>
      </xsl:perform-sort>
    </xsl:variable>
    <xsl:variable name="string-text" as="xs:string" select="string(.)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:sequence select="ttt:merge-non-overlapping-tokenizations($sorted, $string-text, 0)"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()" mode="quotes" priority="2">
    <xsl:variable name="context" select="." as="text()"/>
    <xsl:analyze-string select="." regex="[„“”]">
      <xsl:matching-substring>
        <ttt:t role="quote">
          <xsl:value-of select="."/>
        </ttt:t>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:function name="ttt:merge-non-overlapping-tokenizations" as="node()*">
    <xsl:param name="sorted-tokens" as="element(ttt:t)*"/>
    <xsl:param name="string" as="xs:string?"/>
    <xsl:param name="length" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="not($string)"/>
      <xsl:when test="$length &lt; $sorted-tokens[1]/@start">
        <xsl:variable name="add-substring" as="xs:string" 
          select="substring($string, $length + 1, number($sorted-tokens[1]/@start) - $length)"/>
        <xsl:value-of select="$add-substring"/>
        <xsl:sequence select="ttt:merge-non-overlapping-tokenizations(
                                $sorted-tokens, 
                                $string,
                                $length + string-length($add-substring)
                              )"/>
      </xsl:when>
      <xsl:when test="$length = $sorted-tokens[1]/@start">
        <xsl:copy-of select="$sorted-tokens[1]"/>
        <xsl:sequence select="ttt:merge-non-overlapping-tokenizations(
                                $sorted-tokens[position() gt 1], 
                                $string,
                                $sorted-tokens[1]/@end
                              )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring($string, $length + 1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>