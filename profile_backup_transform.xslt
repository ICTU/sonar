<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template match="/profile/rules/rule">
		+<xsl:value-of select="repositoryKey"/>:<xsl:value-of select="key"/><xsl:apply-templates select="parameters"/>
	</xsl:template>
	<xsl:template match="parameters[string-length() != 0]">|<xsl:for-each select="parameter">
			<xsl:if test="position() > 1">;</xsl:if>
			<xsl:value-of select="key"/>=<xsl:value-of select="value"/>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

