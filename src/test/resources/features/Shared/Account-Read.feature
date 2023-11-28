@basis
@dokumentenaustausch
@medikation
@vitalparameter
@mandatory
@Account-Read
Feature: Lesen der Ressource Account (@Account-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Patient-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der shared.yaml eingegeben worden sein.

      Legen Sie den folgenden Abrechnungsfall in Ihrem System an:
      Status: aktiv
      Typ: ambulant
      Abrechnungsart: Ambulantes Operieren
      Verknüpftes Versicherungsverhältnis: Beliebig (Bitte ID im shared.yaml eingeben)
      Verknüpfter Patient: Der Patient aus Testfall Patient-Read
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Account" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Account anhand der ID
    Then Get FHIR resource at "http://fhirserver/Account/${data.account-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.account-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Account"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKAbrechnungsfall"
    And TGR current response with attribute "$..status.value" matches "active"
    And FHIR current response body evaluates the FHIRPath "type.coding.where(code='AMB').exists()" with error message 'Der Typ des Abrechnungsfalls entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.account-read-identifier-system}' and value='${data.account-read-identifier-value}').exists()" with error message 'Der Abrechnungsfall enthält nicht die korrekte interne Nummer'
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.account-read-identifier-system}' and value='${data.account-read-identifier-value}' and type.coding.where(system='http://terminology.hl7.org/CodeSystem/v2-0203' and code='AN').exists()).exists()" with error message 'Der Abrechnungsfall existiert, ist aber nicht vom korrekten Typ.'
    And FHIR current response body evaluates the FHIRPath "coverage.coverage.exists()" with error message 'Der Abrechnungsfall enthält kein verknüpftes Versicherungsverhältnis'
    And FHIR current response body evaluates the FHIRPath "coverage.extension.where(url = 'http://fhir.de/StructureDefinition/ExtensionAbrechnungsart').exists()" with error message 'Der Abrechnungsfall enthält keine Extension für die Abrechnungsart'
    And FHIR current response body evaluates the FHIRPath "coverage.extension.where(url = 'http://fhir.de/StructureDefinition/ExtensionAbrechnungsart' and value.code = 'AOP' and value.system = 'http://fhir.de/CodeSystem/dkgev/Abrechnungsart').exists()" with error message 'Der Abrechnungsfall enthält nicht die korrekte Abrechnungsart'
