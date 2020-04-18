<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 -->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 	xmlns:xmi="http://www.omg.org/XMI" 
 	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	
	xmlns:pjr="http://www.pjoseph.net"
	xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" 
	xmlns:qvtrelation="http://www.schema.omg.org/spec/QVT/1.0/qvtrelation"
	xmlns:ocl.ecore="http://www.eclipse.org/ocl/1.1.0/Ecore"	

	>
	<xsl:output method="text" encoding="UTF-8" />
	
<!-- INICIO Parámetros de  mapeo entre URLs y nsPrefixes necesarios-->	
	<xsl:variable name="nsPrefixMappings">
		<xsl:element name="mapping">
			<xsl:attribute name="url">http://www.eclipse.org/emf/2002/Ecore</xsl:attribute>
			<xsl:attribute name="nsPrefix">ecore</xsl:attribute>
		</xsl:element>
	</xsl:variable>
<!-- FIN Parámetros de  mapeo entre URLs y nsPrefixes necesarios-->
	
	<xsl:variable name="root" select="/*[1]" />

<!-- BEGIN FUNCTIONS -->
<!-- begin FUNCTION pjr:escapeReservedWords -->
	<xsl:function name="pjr:escapeReservedWords"> <!-- -->
		<xsl:param name="word"/>
		<xsl:choose>
			<xsl:when test="$word='body' or $word='transformation' or $word='when' or $word='where' or $word='domain' or $word='import' or $word='extends' or $word='overrides'">
				<xsl:text>_</xsl:text>
				<xsl:sequence select="$word"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$word"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

<!-- end FUNCTION pjr:escapeReservedWords -->
<!-- begin FUNCTION pjr:getLastElementNameFromReference -->
	<xsl:function name="pjr:getLastElementNameFromReference"> <!-- debuelve el último elemento en un path http...#//x/a = a -->
		<xsl:param name="reference"/>
		<xsl:choose>
			<xsl:when test="contains($reference,'/')">
				<xsl:value-of select="pjr:getLastElementNameFromReference(substring-after($reference,'/'))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$reference"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
<!--  end FUNCTION pjr:getLastElementNameFromReference -->

<!-- begin FUNCTION: getReferrencedVars -->

	<xsl:function name="pjr:getReferrencedVars">
	<!-- devuelve las variables que no se corresponden a dominios -->
		<xsl:param name="rule"/>
		<xsl:param name="root2"/>
		
			<xsl:for-each select="distinct-values($rule//value[@referredVariable]/@referredVariable)">
					<xsl:sequence select="pjr:resolveVariableInRule(.,$root2)"/>
			</xsl:for-each>

		
	</xsl:function>
<!-- end FUNCTION: getReferrencedVars-->


<!-- begin FUNCTION: getNonDomainVars -->

	<xsl:function name="pjr:getNonDomainVars">
	<!-- devuelve las variables que no se corresponden a dominios -->
		<xsl:param name="rule"/>
		<xsl:param name="root2"/>
		
		<xsl:variable name="var_type">
			<xsl:for-each select="$rule/domain">
				<xsl:sequence select="pjr:resolveVariableInRule(./@rootVariable,$root2)"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="domainNames" select="$var_type//@name"/>
		<xsl:for-each select="$rule/variable/@name">
			<xsl:if test="not(pjr:in(.,$domainNames))"><xsl:sequence select=".."/></xsl:if>	
		</xsl:for-each>
		
	</xsl:function>
<!-- end FUNCTION: getNonDomainVars-->

<!-- begin FUNCTION: in -->
	<xsl:function name="pjr:in">
		<xsl:param name="element"/>
		<xsl:param name="container"/>
		<xsl:for-each select="$container">
			<xsl:if test=".=$element">
				<!-- <xsl:message select="concat(.,'=',$element)"/>  -->
				<xsl:sequence select="$element"/>
			</xsl:if>	
		</xsl:for-each>
	</xsl:function>
<!-- end FUNCTION: in-->

<!-- begin FUNCTION: pjr:getNsPrefix -->
	<xsl:function name="pjr:getNsPrefix">
		<xsl:param name="reference" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="starts-with($reference,'http') or starts-with($reference,'platform')">
				<xsl:value-of select="$nsPrefixMappings//mapping[@url=substring-before($reference,'#')]/@nsPrefix"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="document(substring-before($reference,'#'))/node()[1]/@name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
<!-- begin FUNCTION: getNsPrefix -->

<!-- begin FUNCTION: resolveVariableInRule -->
	<xsl:function name="pjr:resolveVariableInRule">
	<xsl:param name="ref"  as="xs:string"/>
	<xsl:param name="contexto" />
	<xsl:message select="'resolveVariableInRule'"/>
		<!--resolveVariableInRule <xsl:message([^/]*)/> -->
		<!--resolveVariableInRule <xsl:message([^/]*)/> -->
		<!--resolveVariableInRule<xsl:message select="concat('contexto: ', $contexto/@name)"/>-->
		<!--resolveVariableInRule<xsl:message select="concat('node-context: ', $contexto/name())"/>-->
		
		<xsl:if test="string-length($ref)&lt;=1"> <!--  si ya hemos acabado, acaba recursividad -->
			<!--resolveVariableInRule <xsl:message([^/]*)/> -->
			<xsl:sequence select="$contexto"/>
			<xsl:message select="'end'"/>
		</xsl:if>
		<xsl:if test="string-length($ref)&gt;1"><!-- si todavía no hemos acabado-->
			<xsl:variable name="current_name_part1">
				<xsl:choose>
				<xsl:when test="starts-with($ref,'//')"><xsl:value-of select="substring-after($ref,'//')"/></xsl:when>
				<xsl:when test="starts-with($ref,'/')"><xsl:value-of select="substring-after($ref,'/')"/></xsl:when>
<!-- 				<xsl:when test="starts-with($ref,'.')"><xsl:value-of select="substring-after($ref,'.')"/></xsl:when> -->
				<xsl:otherwise><xsl:value-of select="substring-after($ref,'#//')"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="part2_slash_position" select="string-length(substring-before($current_name_part1,'/'))"/>
			<xsl:variable name="part2_point_position" select="string-length(substring-before($current_name_part1,'.'))"/>
			<xsl:message select="$contexto/name()"/>
			<xsl:message select="$current_name_part1"/>
			<xsl:message select="$part2_slash_position"/>
			<xsl:message select="$part2_point_position"/>
			
			
			<xsl:variable  name="actualContext">
				<xsl:choose>
				<xsl:when test="(if($part2_slash_position) then $part2_slash_position else 99999)&lt;(if($part2_point_position) then $part2_point_position else 99999)">
				<!-- tenemos una barra -->
					<xsl:choose>
						<xsl:when test="starts-with($ref,'//') or starts-with($ref,'/')">
							<xsl:choose>
								<xsl:when test="substring-before($current_name_part1,'/') castable as xs:integer">
									<xsl:sequence select="$contexto/*[number(substring-before($current_name_part1,'/'))+1]"/>
 									<xsl:message select="concat('actualContext //0/ - /0/: ',$contexto/*[number(substring-before($current_name_part1,'/'))+1]/name())"/>									 
								</xsl:when>
								<xsl:otherwise>
									<xsl:message select="substring-before($current_name_part1,'/')"/>
									<xsl:sequence select="$contexto/child::node()[@name=substring-before($current_name_part1,'/')]"/>
									<xsl:message select="concat('actualContext //x/ - /x/: ',$contexto/child::node()[@name=substring-before($current_name_part1,'/')]/name())"/>	
								</xsl:otherwise>
							</xsl:choose>
						<!--resolveVariableInRule	<xsl:message select="concat('actualContext //x/ - /x/: ',$contexto/child::node()[@name=substring-before($current_name_part1,'/')]/@name)"/> -->
						
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="document(substring-before($ref,'#'))"/>
							<xsl:message select="concat('actualContext x#// : ',substring-before($ref,'#'))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="(if($part2_slash_position) then $part2_slash_position else 99999)&gt;(if($part2_point_position) then $part2_point_position else 99999)">
				<!-- tenemos un punto -->
					<xsl:choose>
						<xsl:when test="starts-with($ref,'//') or starts-with($ref,'/')">
							<!--resolveVariableInRule <xsl:message([^/]*)/> -->
							<xsl:sequence select="$contexto/child::node()[@name=substring-before($current_name_part1,'.')][1+number(substring($current_name_part1,$part2_point_position+2,string-length($current_name_part1)-($part2_point_position)-1))]"/>
							<!--resolveVariableInRule<xsl:message select="concat('actualContext //x. - /x. : ',$contexto/child::node()[@name=substring-before($current_name_part1,'.')][1+number(substring($current_name_part1,$part2_point_position+2,string-length($current_name_part1)-($part2_point_position)-1))]/name())"/>-->
							<xsl:message select="concat('actualContext //x. - /x. : ',$contexto/child::node()[@name=substring-before($current_name_part1,'.')][1+number(substring($current_name_part1,$part2_point_position+2,string-length($current_name_part1)-($part2_point_position)-1))]/name())"/>
						</xsl:when>
						<xsl:otherwise>
							<!--resolveVariableInRule <xsl:message([^/]*)/> -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="(if($part2_slash_position) then $part2_slash_position else 99999)=(if($part2_point_position) then $part2_point_position else 99999)">
					<!--  fin de cadena-->
					<xsl:choose>
						<xsl:when test="starts-with($ref,'//') or starts-with($ref,'/')">
							<xsl:choose>
								<xsl:when test="$current_name_part1 castable as xs:integer">
									<xsl:sequence select="$contexto/*[position()=(number($current_name_part1)+1)]"/>
									<xsl:message select="concat('actualContext /x : ',$contexto/*[position()=(number($current_name_part1)+1)]/name())"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="$contexto/child::node()[@name=$current_name_part1]"/>
									<xsl:message select="concat('actualContext /x : ',$contexto/*[@name=$current_name_part1]/name())"/>
								</xsl:otherwise>
							</xsl:choose>							
							
							
						</xsl:when>
						<xsl:otherwise>
							<!--resolveVariableInRule <xsl:message terminate="yes">Error! <xsl:value-of select="$ref"/> </xsl:message> -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<!--resolveVariableInRule<xsl:message select="concat('actualContext: ',$actualContext/node()/name())"/>-->
			
			
			<xsl:variable name="newRef">
				<xsl:choose>
				<xsl:when test="(if($part2_slash_position) then $part2_slash_position else 99999)&lt;(if($part2_point_position) then $part2_point_position else 99999)">
				<!-- tenemos una barra -->
					<xsl:value-of select="concat('/',substring-after($current_name_part1,'/'))"/></xsl:when>
				<xsl:when test="(if($part2_slash_position) then $part2_slash_position else 99999)&gt;(if($part2_point_position) then $part2_point_position else 99999)">
				<!-- tenemos un punto -->
					<xsl:value-of select="concat('/',substring-after($current_name_part1,'/'))"/></xsl:when>
				<xsl:when test="(if($part2_slash_position) then $part2_slash_position else 99999)=(if($part2_point_position) then $part2_point_position else 99999)">
					<!--  fin de cadena-->
				</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<!--resolveVariableInRule <xsl:message([^/]*)/> -->
			<xsl:sequence select="pjr:resolveVariableInRule($newRef,$actualContext/node()[1])"/>	
		</xsl:if>
	</xsl:function>
<!-- end FUNCTION: resolveVariableInRule -->
<!-- END FUNCTIONS -->

<!-- inici de TEMPLATES -->
<xsl:template match="  node() | @*">
<!--  netejem els estils -->
</xsl:template>
<xsl:template match="xmi:XMI" >
	<xsl:apply-templates/>	
</xsl:template>
<xsl:template match="qvtrelation:RelationalTransformation" >
	<xsl:message select="'qvtrelation:RelationalTransformation'"/>
	<xsl:text>transformation copy</xsl:text><xsl:value-of select="@name"/><xsl:text> ( </xsl:text>
	<xsl:for-each select="modelParameter">
		<xsl:if test="position()!=1"><xsl:text>,</xsl:text></xsl:if>
<!-- 		<xsl:copy-of select="."/> -->
		<xsl:value-of select="@name"/><xsl:text>:</xsl:text><xsl:value-of select="if(pjr:getNsPrefix(./usedPackage/@href)) then  pjr:getNsPrefix(./usedPackage/@href) else pjr:getNsPrefix(./@usedPackage)"/>
	</xsl:for-each>
	<xsl:text> ) {
</xsl:text>
		<xsl:apply-templates/>
	<xsl:text>
}</xsl:text>
	</xsl:template>
	
	<xsl:template match="rule">
	<xsl:if test="@isTopLevel and @isTopLevel='true'"><xsl:text>top </xsl:text></xsl:if>
	<xsl:text>	relation </xsl:text><xsl:value-of select="@name"/><xsl:text> {
</xsl:text>
	<xsl:apply-templates select="pjr:getReferrencedVars(.,$root)" mode="variableDefinition"/>
	<xsl:apply-templates/>	
	<xsl:text>	}
</xsl:text>
	</xsl:template>
	
	<xsl:template match="domain">
	<xsl:variable name="var_type" select="pjr:resolveVariableInRule(@rootVariable,$root)"/>
	<xsl:if test="@isCheckable and @isCheckable='true'"><xsl:text>		checkonly domain source </xsl:text></xsl:if>
	<xsl:if test="@isEnforceable and @isEnforceable='true'"><xsl:text>		enforce domain target </xsl:text></xsl:if>
	<xsl:value-of select="$var_type/@name"/><xsl:text>:</xsl:text>
	<xsl:value-of select="pjr:getNsPrefix($var_type/eType/@href)"/>
	<xsl:text>::</xsl:text><xsl:value-of select="substring-after($var_type/eType/@href,'#//')"/>
	<xsl:text>{</xsl:text><xsl:apply-templates/><xsl:text>	};
</xsl:text>
	</xsl:template>	
	
	<xsl:template match="variable" mode="variableDefinition">
		<xsl:text>		</xsl:text><xsl:value-of select="pjr:escapeReservedWords(@name)"/><xsl:text>:</xsl:text>
		<xsl:choose>
		<xsl:when test="./eType">
			<xsl:value-of select="pjr:getNsPrefix(./eType/@href)"/>
			<xsl:text>::</xsl:text>
			<xsl:value-of select="substring-after(./eType/@href,'#//')"/>
			<xsl:text>;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="eType" select="pjr:resolveVariableInRule(@eType,$root)"/>
			<xsl:message select="$eType/name()"/>
			<xsl:choose>
				<xsl:when test="contains($eType/name(),'OrderedSetType')">
					<xsl:text>OrderedSet(</xsl:text><xsl:value-of select="pjr:getNsPrefix($eType/elementType/@href)"/><xsl:text>::</xsl:text><xsl:value-of select="substring-after($eType/elementType/@href,'#//')"/><xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="contains($eType/name(),'SetType')">
					<xsl:text>Set(</xsl:text><xsl:value-of select="pjr:getNsPrefix($eType/elementType/@href)"/><xsl:text>::</xsl:text><xsl:value-of select="substring-after($eType/elementType/@href,'#//')"/><xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="contains($eType/name(),'SequenceType')">
					<xsl:text>Sequence(</xsl:text><xsl:value-of select="pjr:getNsPrefix($eType/elementType/@href)"/><xsl:text>::</xsl:text><xsl:value-of select="substring-after($eType/elementType/@href,'#//')"/><xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="contains($eType/name(),'BagType')">
					<xsl:text>Bag(</xsl:text><xsl:value-of select="pjr:getNsPrefix($eType/elementType/@href)"/><xsl:text>::</xsl:text><xsl:value-of select="substring-after($eType/elementType/@href,'#//')"/><xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="pjr:getNsPrefix($eType/elementType/@href)"/>
					<xsl:text>::</xsl:text>
					<xsl:value-of select="substring-after($eType/elementType/@href,'#//')"/>					
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>;</xsl:text>
		</xsl:otherwise>
		</xsl:choose>	
	
<!-- <xsl:value-of select="prefix-from-QName(node-name(document(substring-before('Copia%20de%20petriNet.ecore#//CPlace','#//'))/node()[1]))"/> -->
	
<xsl:text>
</xsl:text>	
	</xsl:template>
	
	<xsl:template match="pattern">
		<xsl:if test="@bindsTo=../@rootVariable"> 
		<!-- el domainPattern que tiene el relationDomain -->
			<xsl:apply-templates/>
		</xsl:if>
		<xsl:if test="@bindsTo!=../@rootVariable"> 
		<!-- el pattern al que pertenece un predicate en un where o when de una relation, no se suele serialzar así ya que es un backwards reference, así que lo ignoramos-->
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="templateExpression"><!-- 
		
		el templateExpression de un domainPattern 
		
		--><xsl:choose><xsl:when test="@xsi:type='qvttemplate:ObjectTemplateExp' or @xsi:type='qvtrelation:ObjectTemplateExp'"><!-- 
			hace un bindsTo a la variable del dominio 
			 tiene un elemento eType del tipo de la variable del dominio 
			--><xsl:apply-templates/><!-- 	
	 	--></xsl:when><!--
		--><xsl:when test="@xsi:type='qvttemplate:CollectionTemplateExp'"><!-- 
			 --><xsl:apply-templates/><!--
		 --></xsl:when><!--
		 --></xsl:choose><!--
	--></xsl:template>
	<xsl:template match="referredCollectionType">
			<xsl:message select="concat('  @@  TEST: Tipo de valor con hijo desconocido: referredCollectionType_',@xsi:type,'_')" />
			<xsl:message select="concat('  @@  ERROR: en medini no se puede hacer esto para un tipo en concreto',@xsi:type,'_')" terminate="yes" />
	</xsl:template>

	<xsl:template match="part"><!--  	la part de un ObjecctTemplateExp del templateExpression del pattern domainPattern del dominio
		 un objeto PropertyTemplateItem 
		--><xsl:text>
			,</xsl:text>
		<xsl:apply-templates select="./value"/></xsl:template>	
	
	<xsl:template match="value">
		<xsl:value-of select="pjr:escapeReservedWords(pjr:getLastElementNameFromReference(../referredProperty/@href))"/><xsl:text>=</xsl:text>
		
		<xsl:choose>
			<xsl:when test="@xsi:type='ocl.ecore:VariableExp'">
				<xsl:value-of select="pjr:getLastElementNameFromReference(@referredVariable)"/>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="var_type" select="pjr:resolveVariableInRule(@bindsTo ,$root)"/>
				<xsl:value-of select="pjr:getLastElementNameFromReference(@bindsTo)"/>
				<xsl:choose>
					<xsl:when test="$var_type/eType">
						<xsl:text>:</xsl:text><xsl:value-of select="pjr:getNsPrefix($var_type/eType/@href)"/>
						<xsl:text>::</xsl:text><xsl:value-of select="substring-after($var_type/eType/@href,'#//')"/>
						<xsl:text> {
</xsl:text><xsl:apply-templates/><xsl:text>	}
</xsl:text>
					</xsl:when>
					<xsl:otherwise>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="where">
	<xsl:text>		where{
			</xsl:text><xsl:apply-templates/><xsl:text>
		}
</xsl:text>	
	</xsl:template>
	
	<xsl:template match="when">
	<xsl:text>
		when{
			</xsl:text><xsl:apply-templates/><xsl:text>
		}
</xsl:text>	
	</xsl:template>
	<xsl:template match="predicate">
<xsl:if test="count(preceding-sibling::*)>0"><xsl:text>

			</xsl:text></xsl:if><xsl:apply-templates/><xsl:text>;</xsl:text>
	</xsl:template>
	
	<xsl:template match="*[@xsi:type='qvtrelation:RelationCallExp']">
<!-- 		<xsl:variable name="conditionExpression" select="pjr:resolveVariableInRule(@referredRelation)"/> -->
		<xsl:value-of select="pjr:getLastElementNameFromReference(@referredRelation)"/><xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="*[@xsi:type='ocl.ecore:OperationCallExp']">
		<xsl:value-of select="pjr:getLastElementNameFromReference(referredOperation/@href)"/><xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>	
	</xsl:template>
	
	<xsl:template match="argument">
		<xsl:if test="count(preceding-sibling::*)>0"><xsl:text>,</xsl:text></xsl:if>
		<xsl:text>
			</xsl:text><xsl:value-of select="pjr:getLastElementNameFromReference(@referredVariable)"/>	
	</xsl:template>
</xsl:stylesheet>