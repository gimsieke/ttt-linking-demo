<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ttt="http://transpect.io/tokenized-to-tree" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:tr="http://transpect.io"
  name="link-dbk" type="ttt:link-dbk">

  <p:input port="source" primary="true"/>
  <p:input port="prepare-input-xsl">
    <p:document href="http://this.transpect.io/a9s/common/tokenized-to-tree/prepare-input.xsl"/>
  </p:input>
  <p:input port="prepare-target-list-xsl">
    <p:document href="http://this.transpect.io/a9s/common/tokenized-to-tree/prepare-target-list.xsl"/>
  </p:input>
  <p:input port="find-candidates-xsl">
    <p:document href="http://this.transpect.io/a9s/common/tokenized-to-tree/find-candidates.xsl"/>
  </p:input>
  <p:input port="patch-token-stylesheet">
    <p:document href="http://transpect.io/tokenized-to-tree/xsl/patch-token-results.xsl"/>
  </p:input>
  <p:input port="re-insert-placeholders-stylesheet">
    <p:document href="http://this.transpect.io/a9s/common/tokenized-to-tree/re-insert-placeholders.xsl"/>
  </p:input>

  <p:output port="result" primary="true"/>
  <p:serialization port="result" omit-xml-declaration="false"/>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>

  <p:import href="http://transpect.io/tokenized-to-tree/xpl/ttt-1-prepare-input.xpl"/>
  <p:import href="http://transpect.io/tokenized-to-tree/xpl/ttt-3-integrate-tokenizer-results.xpl"/>
  <p:import href="http://transpect.io/tokenized-to-tree/xpl/ttt-5-expand-placeholders.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/re-attach-out-of-doc-PIs/xpl/re-attach-out-of-doc-PIs.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:xslt name="create-target-list">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="prepare-target-list-xsl" step="link-dbk"/>
    </p:input>
  </p:xslt>
  <tr:store-debug pipeline-step="01_target-list">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink name="sink1"/>

  <ttt:prepare-input name="prepare-input">
    <p:input port="source">
      <p:pipe port="source" step="link-dbk"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="prepare-input-xsl" step="link-dbk"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </ttt:prepare-input>

  <p:sink name="sink5"/>

  <p:xslt name="mark-candidates">
    <p:input port="source">
      <p:pipe port="result" step="prepare-input"/>
      <p:pipe port="result" step="create-target-list"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="find-candidates-xsl" step="link-dbk"/>
    </p:input>
  </p:xslt>
  <tr:store-debug pipeline-step="tokenized-to-tree/2_find-candidates">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:delete match="@ttt:chapter-id"/>

  <ttt:process-paras name="integrate-results">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="patch-token-stylesheet">
      <p:pipe port="patch-token-stylesheet" step="link-dbk"/>
    </p:input>
  </ttt:process-paras>

  <ttt:merge-results name="merge-results">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="source">
      <p:pipe port="with-ids" step="prepare-input"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="re-insert-placeholders-stylesheet" step="link-dbk"/>
    </p:input>
    <p:input port="params">
      <p:empty/>
    </p:input>
  </ttt:merge-results>

  <tr:re-attach-out-of-doc-PIs name="re-attach-out-of-doc-PIs">
    <p:with-option name="file-uri" select="base-uri(/*)" >
      <p:pipe port="source" step="link-dbk"/>
    </p:with-option>
  </tr:re-attach-out-of-doc-PIs>
  
</p:declare-step>
