<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xmi="http://www.omg.org/spec/XMI/20110701"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:uml="http://www.eclipse.org/uml2/4.0.0/UML"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pjr="http://www.pjoseph.net"
	id="functions">
	
	<xsl:function name="pjr:classes" pjr:type="Class[]" pjr:doc="Select all classes">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:sequence select="$document//*[@xmi:type='uml:Class']"/>
	</xsl:function>
	
	<xsl:function name="pjr:interfaces" pjr:type="Interface[]" pjr:doc="Select all Interfaces">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:sequence select="$document//*[@xmi:type='uml:Interface']"/>
	</xsl:function>
	
	<xsl:function name="pjr:properties" pjr:type="Element[]" pjr:doc="Select navigable class properties beeing attributes, associations,aggregations, or compositions">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classId" as="xs:string" pjr:type="class"/>
		
		
		
		<!--propiedades que pertenecen a la clase y propiedades que pertenecen a la asociación -->
		<xsl:variable name="directProperties" select="$document//*[@xmi:type='uml:Property' and  parent::*[@xmi:id=$classId]]"/>
		<xsl:sequence select="$directProperties"/>
		
		<xsl:variable name="indirectProperties" select="$document//*[@xmi:type='uml:Association' and child::*[@xmi:type='uml:Property' and  @type=$classId]]/child::*[@xmi:type='uml:Property' and @type!=$classId]"/>
		
		<!-- Generamos la secuencia de propiedades navegables definidas por las asociaciones indirectas-->
		<xsl:for-each select="$indirectProperties" >
			<xsl:variable name="curr" select="."/>
			<xsl:if test="$document//*[@xmi:type='uml:Association'  and contains(@navigableOwnedEnd, $curr/@xmi:id)]">
				<xsl:sequence select="."/>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>

		
	<xsl:function name="pjr:operations" pjr:type="Opertion[]" pjr:doc="Select operations of a classifier wiithout including inherited">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classifierId" as="xs:string" pjr:type="classifier"/>
		
		<xsl:sequence select="$document//*[@xmi:id=$classifierId]/*[@xmi:type='uml:Operation']"/>
		
	</xsl:function>
	
	
	<xsl:function name="pjr:parameters" pjr:type="Parameter[]" pjr:doc="Select operation parameters not of return type">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="operationId"  as="xs:string" pjr:type="operation"/>
		
		<xsl:sequence select="$document//*[@xmi:type='uml:Operation' and @xmi:id=$operationId]/*[@xmi:type='uml:Parameter'  and  (not (@direction) or @direction!='return') ] "/>
		
	</xsl:function>
	
	<xsl:function name="pjr:returnParam" pjr:type="Parameter[]" pjr:doc="Select operation parameters of return type">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="operationId" as="xs:string" pjr:type="operation"/>
		
		<xsl:sequence select="$document//*[@xmi:type='uml:Operation' and @xmi:id=$operationId]/*[@xmi:type='uml:Parameter'  and  @direction='return' ] "/>
		
	</xsl:function>
	
	<xsl:function name="pjr:generalized" pjr:type="Classifier[]" pjr:doc="Select generalized classifier of another classifier">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classifierId" as="xs:string" pjr:type="class"/>

		<xsl:sequence select="$document//*[@xmi:id=//*[@xmi:id=$classifierId]/*[@xmi:type='uml:Generalization']/@general]"/>

	</xsl:function>
	
	<xsl:function name="pjr:realized" pjr:type="Classifier[]" pjr:doc="Select realized classifier of another classifier">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classifierId" as="xs:string" pjr:type="class"/>

		<xsl:sequence select="$document//*[@xmi:id=//*[(@xmi:type='uml:InterfaceRealization' or @xmi:type='uml:Realization') and @client=$classifierId]/@supplier]"/>

	</xsl:function>
	
	<xsl:function name="pjr:throws" pjr:type="Classifier[]" pjr:doc="Select thrown classifier by an ooperation">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="operationId" as="xs:string" pjr:type="operation"/>

			<xsl:for-each select="tokenize($document//*[(@xmi:type='uml:Operation') and @xmi:id=$operationId]/@raisedException,'\s')">
				<xsl:variable name="curr" select="."/>
				<xsl:sequence select="$document//*[@xmi:id=$curr]"/>
			</xsl:for-each>
	</xsl:function>
	
	<xsl:function name="pjr:visibility" pjr:type="String" pjr:doc="Returns visibility of a NamedElement">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="elementId" as="xs:string" pjr:type="NamedElement"/>
		<xsl:choose>
			<xsl:when test="$document//*[@xmi:id=$elementId]/@visibility">
				<xsl:value-of select="$document//*[@xmi:id=$elementId]/@visibility"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'public'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="pjr:isAbstract" pjr:type="Boolean-String" pjr:doc="returns if an element is marked as abstract">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classifierId" as="xs:string" pjr:type="classifier"/>
		
		<xsl:choose>
			<xsl:when test="$document//*[@xmi:id=$classifierId]/@isAbstract">
				<xsl:value-of select="$document//*[@xmi:id=$classifierId]/@isAbstract"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="pjr:isStatic" pjr:type="Boolean-String" pjr:doc="returns if an element is marked as static">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classifierId" as="xs:string" pjr:type="classifier"/>
		
		<xsl:choose>
			<xsl:when test="$document//*[@xmi:id=$classifierId]/@isStatic">
				<xsl:value-of select="$document//*[@xmi:id=$classifierId]/@isStatic"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="pjr:isReadOnly" pjr:type="Boolean-String" pjr:doc="returns if an element is marked as readonly">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="classifierId" as="xs:string" pjr:type="classifier"/>
		
		<xsl:choose>
			<xsl:when test="$document//*[@xmi:id=$classifierId]/@isReadOnly">
				<xsl:value-of select="$document//*[@xmi:id=$classifierId]/@isReadOnly"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="pjr:packages" pjr:type="String" pjr:doc="returns the packages containing the packageableElement">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="packageableElementId" as="xs:string" pjr:type="PackageableElement"/>
	
		<xsl:sequence select="$document//*[@xmi:id=$packageableElementId]/ancestor::*[@xmi:type='uml:Package']" />
	</xsl:function>
	
	<xsl:function name="pjr:packageName" pjr:type="String" pjr:doc="returns the packages path as '.' concatenated">
		<xsl:param name="document" pjr:type="root"/>
		<xsl:param name="packageableElementId" as="xs:string" pjr:type="PackageableElement"/>

<!-- 		<xsl:message select="$packageableElementId" /> -->
		<xsl:variable name="parentPackages" select="$document//*[@xmi:id=$packageableElementId]/ancestor::*[@xmi:type='uml:Package']/@name" /> 
		<xsl:sequence select="string-join($parentPackages,'.')"/>
	</xsl:function>

	<xsl:function name="pjr:lowerFirst">
		<xsl:param name="var" pjr:type="xs:string"/>
		<xsl:sequence select="concat(lower-case(substring($var,1,1)),substring($var,2))"/>
	</xsl:function>

	<xsl:function name="pjr:nest">
<xsl:param name="nestingLevel" pjr:type="xs:double"/>
<xsl:if test="$nestingLevel!=0"><xsl:text>	</xsl:text><xsl:sequence select="pjr:nest(-1+$nestingLevel)"/></xsl:if>
</xsl:function>


</xsl:stylesheet>