@basis
@mandatory
@Coverage-Read-Private
Feature: Lesen der Ressource Coverage (@Coverage-Read-Private)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der basis.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)
      Legen Sie folgendes Versicherungsverhältnis in Ihrem System an:
      Begünstigter: Beliebig (Bitte ID im Titus GUI eingeben)
      Status: aktiv/gültig
      Versicherungsart: Selbstzahler
      Kostenübernehmer: Gleich dem Begünstigten
      Inhaber der Versicherungspolice (Display): Mustermann
      Optional -  Inhaber der Versicherungspolice (Referenz): Gleich dem Begünstigten (Bitte ID in der basis.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Coverage" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer Coverage-Ressource anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Coverage/${data.coverage-read-private-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.coverage-read-private-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Coverage"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisSelbstzahler"
    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..code.value" matches "SEL"
    And FHIR current response body evaluates the FHIRPath 'beneficiary.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message 'Kostenübernehmer entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'payor.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message 'Inhaber der Kostenübernahme entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "subscriber.display = 'Mustermann'" with error message 'Begünstigter entspricht nicht dem Erwartungswert'
