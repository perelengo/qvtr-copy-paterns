<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/spec/XMI/20110701"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:uml="http://www.eclipse.org/uml2/4.0.0/UML"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pjr="http://www.pjoseph.net">
	<xsl:output method="text" encoding="ISO-8859-1" />
<xsl:include href="functions.xsl"/>	

	<xsl:variable name="root" select="/" />
	
	<xsl:template match="/">
	transformation model_mapping(source : uml, target : uml) {
		<xsl:apply-templates/>
		
	
	}
	</xsl:template>
	
	<xsl:template match="uml:Model">
	top relation <xsl:value-of select="pjr:lowerFirst(local-name())"/>_<xsl:value-of select="pjr:lowerFirst(local-name())"/> {

			<xsl:apply-templates select="//@*[not(contains(name(),'xmi'))]" mode="var_definition">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>

			checkonly domain source <xsl:value-of select="concat(pjr:lowerFirst(local-name()),'1')"/> : <xsl:value-of select="replace(name(),':','::')"/> {
	
			<xsl:apply-templates mode="domain_variable_set">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="@*[not(contains(name(),'xmi'))]" mode="domain_variable_set">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
	
			};
			
			enforce domain target  <xsl:value-of select="concat(pjr:lowerFirst(local-name()),'2')"/> : <xsl:value-of select="replace(name(),':','::')"/> {
			<xsl:apply-templates mode="domain_variable_set">
				<xsl:with-param name="domainCounter">2</xsl:with-param>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="@*[not(contains(name(),'xmi'))]" mode="domain_variable_set">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
			};
	
			where  {
			<xsl:apply-templates mode="where_constraint">
			</xsl:apply-templates>
			}
	
		}
		<xsl:apply-templates>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*">


		relation <xsl:value-of select="pjr:lowerFirst(substring-after(@xmi:type,':'))"/>_<xsl:value-of select="pjr:lowerFirst(substring-after(@xmi:type,':'))"/> {

			<xsl:apply-templates select="@*[not(contains(name(),'xmi'))]" mode="var_definition">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
			
			checkonly domain source <xsl:value-of select="concat(pjr:lowerFirst(substring-after(@xmi:type,':')),'1')"/> : <xsl:value-of select="replace(@xmi:type,':','::')" /> {
	
			<xsl:apply-templates mode="domain_variable_set">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="@*[not(contains(name(),'xmi'))]" mode="domain_variable_set">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
	
			};
			
			enforce domain target <xsl:value-of select="concat(pjr:lowerFirst(substring-after(@xmi:type,':')),'2')"/> : <xsl:value-of select="replace(@xmi:type,':','::')" /> {
			<xsl:apply-templates mode="domain_variable_set">
				<xsl:with-param name="domainCounter">2</xsl:with-param>
			</xsl:apply-templates>
			
			<xsl:apply-templates select="@*[not(contains(name(),'xmi'))]" mode="domain_variable_set">
				<xsl:with-param name="domainCounter">1</xsl:with-param>
			</xsl:apply-templates>
			};
	
			where  {
			<xsl:apply-templates mode="where_constraint">
			</xsl:apply-templates>
			}
	
		}
		<xsl:apply-templates>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="domain_variable_set">
	<xsl:param name="domainCounter"/>
			<xsl:message select="."/>
			<xsl:message select="'________________________________________'"/>
			
			<xsl:variable name="type" select="./@xmi:type"/>
			<xsl:variable name="_name" select="./@name"/>
			<xsl:if test="position()!=1">				
			,</xsl:if><xsl:value-of select="local-name()"/> = <xsl:value-of select="concat(pjr:lowerFirst(substring-after(@xmi:type,':')),$domainCounter,':',replace(./@xmi:type,':','::'))"/>{<xsl:apply-templates mode="domain_variable_set">
				<xsl:with-param name="domainCounter"><xsl:value-of select="1"/></xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates select="@*[not(contains(name(),'xmi'))]" mode="domain_variable_set">
				<xsl:with-param name="domainCounter"><xsl:value-of select="1"/></xsl:with-param>
			</xsl:apply-templates>
			}
	</xsl:template>
		
	<xsl:template match="*" mode="where_constraint">
			<xsl:message select="."/>
			<xsl:message select="'________________________________________'"/>
			
			<xsl:variable name="type" select="./@xmi:type"/>
			<xsl:variable name="_name" select="./@name"/>
			
			<xsl:value-of select="pjr:lowerFirst(substring-after(@xmi:type,':'))"/>_<xsl:value-of select="pjr:lowerFirst(substring-after(@xmi:type,':'))"/>(<xsl:value-of select="concat(pjr:lowerFirst($_name),',',pjr:lowerFirst($_name))"/>);
	</xsl:template>


	
	
	<xsl:template match="@*" mode="domain_variable_set">
	<xsl:param name="domainCounter"/>
			<xsl:message select="."/>
			<xsl:message select="'________________________________________'"/>
			<xsl:if test="position()=1">	
				,<xsl:value-of select="name()"/> = var_<xsl:value-of select="concat(pjr:lowerFirst(replace(../@xmi:type,':','_')),'_',replace(name(),':','_'),$domainCounter)"/>
			</xsl:if>
			<xsl:if test="position()!=1">
				,<xsl:value-of select="name()"/> = var_<xsl:value-of select="concat(pjr:lowerFirst(replace(../@xmi:type,':','_')),'_',replace(name(),':','_'),$domainCounter)"/>
			</xsl:if>
						
	</xsl:template>



	<xsl:template match="@*" mode="var_definition">
	<xsl:param name="domainCounter"/>
			var_<xsl:value-of select="concat(pjr:lowerFirst(replace(../@xmi:type,':','_')),'_',replace(name(),':','_'),$domainCounter)"/> : String;
	</xsl:template>


<!-- 

			actor = a:Actor {
			},
			subsystem = s:Component {
				name = componentName,
				ownedUseCase = u:UseCase {
					name = useCaseName
				},
				useCase = u
			},

			association = ass : Association {
				name = assName,
				ownedEnd = end1:Property {
					name=assEnd1Name,
					type=a,
					association=ass
				},
				ownedEnd = end2:Property {
					name=assEnd2Name,
					type=s,
					association=ass
				}
			}
			
		};
		
		enforce domain target model : uml::Model {
			actor = a,
			subsystem = s,
			association = ass,

		};

 -->
</xsl:stylesheet>
