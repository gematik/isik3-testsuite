@basis
@mandatory
@RelatedPerson-Search
Feature: Testen von Suchparametern gegen relatedperson-read (@RelatedPerson-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall RelatedPerson-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "RelatedPerson" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "RelatedPerson" and searchParam.where(name = "_id" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "RelatedPerson" and searchParam.where(name = "patient" and type = "reference").exists()).exists()
    """

  Scenario: Suche nach Angehoerigen anhand der ID
    Then Get FHIR resource at "http://fhirserver/RelatedPerson/?_id=${data.relatedperson-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(id.replaceMatches("/_history/.+","").matches("${data.relatedperson-read-id}"))' with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "RelatedPerson" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKAngehoeriger"

  Scenario: Suche nach Angehoerigen anhand einer Patienten ID
    Then Get FHIR resource at "http://fhirserver/RelatedPerson/?patient=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(patient.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}"))' with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.relatedperson-read-id}")).count() = 1' with error message 'Die gesuchte Angehoerige ${data.relatedperson-read-id} ist nicht im Responsebundle enthalten'
