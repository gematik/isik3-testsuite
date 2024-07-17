@basis
@optional
@Condition-Search-ClinicalStatus-Optional
Feature: Testen des clinical-status-Suchparameters (@Condition-Search-ClinicalStatus-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters clinical-status finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      -- Der Testfall Condition-Read-Active muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "clinical-status" and type = "token").exists()).exists()
    """

  Scenario: Suche der Diagnose anhand des klinischen Status
    Then Get FHIR resource at "http://fhirserver/Condition/?clinical-status=http://terminology.hl7.org/CodeSystem/condition-clinical%7Cactive" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(clinicalStatus.coding.code.where($this = 'active').exists())" with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Diagnose anhand der ID und dem klinischen Status
    Then Get FHIR resource at "http://fhirserver/Condition/?_id=${data.condition-read-active-id}&clinical-status=http://terminology.hl7.org/CodeSystem/condition-clinical%7Cinactive" with content type "json"
    And bundle does not contain resource "Condition" with ID "${data.condition-read-active-id}" with error message "Die gesuchte Diagnose ${data.condition-read-active-id}} darf hier nicht zurückgegeben werden"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(clinicalStatus.coding.code.where($this = "active").exists().not())' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Diagnose anhand des klinischen Status mit :not Modifier
    Then Get FHIR resource at "http://fhirserver/Condition/?clinical-status:not=http://terminology.hl7.org/CodeSystem/condition-clinical%7Cinactive" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(clinicalStatus.coding.code.where($this = "inactive").exists().not())' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
