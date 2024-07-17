@basis
@mandatory
@Coverage-Read-Private
Feature: Lesen der Ressource Coverage (@Coverage-Read-Private)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Patient-Read muss zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'coverage-read-private-id' hinterlegt sein.

      Testdatensatz (Name: Wert)
      Legen Sie folgendes Versicherungsverhältnis in Ihrem System an:
      Begünstigter: Der Patient aus Testfall Patient-Read
      Status: aktiv/gültig
      Versicherungsart: Selbstzahler
      Kostenübernehmer: Gleich dem Begünstigten
      Inhaber der Versicherungspolice (Display): Graf von und zu Mustermann
      Optional -  Inhaber der Versicherungspolice (Referenz): Gleich dem Begünstigten
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Coverage"

  Scenario: Read einer Coverage-Ressource anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Coverage/${data.coverage-read-private-id}" with content type "xml"
    And resource has ID "${data.coverage-read-private-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKVersicherungsverhaeltnisSelbstzahler"
    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..code.value" matches "SEL"
    And element "beneficiary" references resource with ID "${data.patient-read-id}" with error message "Kostenübernehmer entspricht nicht dem Erwartungswert"
    And element "payor" references resource with ID "${data.patient-read-id}" with error message "Inhaber der Kostenübernahme entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "subscriber.display.contains('Graf von und zu Mustermann')" with error message 'Begünstigter entspricht nicht dem Erwartungswert'
