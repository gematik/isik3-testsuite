@basis
@dokumentenaustausch
@terminplanung
@vitalparameter
@mandatory
@Patient-Search
Feature: Testen von Suchparametern gegen die Patienten Ressource (@Patient-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Patient-Read & Patient-Read-Extended muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Patient" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Patient" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue | searchParamType |
      | _id              | token           |
      | identifier       | token           |
      | given            | string          |
      | family           | string          |
      | birthdate        | date            |
      | gender           | token           |

  Scenario: Suche nach Patienten anhand der ID
    Then Get FHIR resource at "http://fhirserver/Patient/?_id=${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.where(id.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")).count() = 1' with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Patient" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient"

  Scenario: Suche nach Patienten anhand des Identifiers
    Then Get FHIR resource at "http://fhirserver/Patient/?identifier=http://fhir.de/sid/gkv/kvid-10%7CX485231029" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(identifier.where($this.system = 'http://fhir.de/sid/gkv/kvid-10' and $this.value = 'X485231029').exists())" with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'

  Scenario: Suche nach Patienten anhand des Vornamens
    Then Get FHIR resource at "http://fhirserver/Patient/?given=Max" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.given.where($this.startsWith('Max')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patienten mit Parameter family
    Then Get FHIR resource at "http://fhirserver/Patient/?family=Graf%20von%20und%20zu%20Mustermann" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.family.where($this.startsWith('Graf von und zu Mustermann')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche eines Patienten anhand des Geburtsdatums
    Then Get FHIR resource at "http://fhirserver/Patient/?birthdate=1968-05-12" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(birthDate = @1968-05-12)" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche eines Patienten anhand der ID und des Geburtsdatums
    Then Get FHIR resource at "http://fhirserver/Patient/?_id=${data.patient-read-id}&birthdate=1968-05-12" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(birthDate = @1968-05-12)" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).count() = 1" with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'

  Scenario: Suche nach Patienten anhand der ID und des Geschlechts
    Then Get FHIR resource at "http://fhirserver/Patient/?gender=male" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(gender = 'male')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patienten anhand der ID und des Geschlechts
    Then Get FHIR resource at "http://fhirserver/Patient/?_id=${data.patient-read-id}&gender=male" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(gender = 'male')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).count() = 1" with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'

  Scenario: Suche eines Patienten mittels family:contains
    Then Get FHIR resource at "http://fhirserver/Patient/?_id=${data.patient-read-id}&family:contains=Mustermann" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.family.where($this.contains('Mustermann')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).count() = 1" with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'

  Scenario: Suche nach Patient*innen anhand des Nachnamens mit Sonderzeichen
    Then Get FHIR resource at "http://fhirserver/Patient/?family:contains=Gr%C3%A4fin%20M%C3%BC%C3%9Fterm%C3%A1nn" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.where(family = 'Gräfin Müßtermánn').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patient*innen anhand des Vornamens mit Sonderzeichen
    Then Get FHIR resource at "http://fhirserver/Patient/?given:contains=An%26na%5C%2CVic%24tor%7Ca" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.where(given.contains('An&na,Vic$tor|a')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'


  Scenario: Suche eines Patienten mittels birthdate=gt
    Then Get FHIR resource at "http://fhirserver/Patient/?birthdate=gt1955-07-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(birthDate > @1955-07-01)" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patient*innen anhand des Kontakts
    Then Get FHIR resource at "http://fhirserver/Patient/?_has:Encounter:patient:_id=${data.encounter-read-in-progress-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).count() = 1" with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'

  Scenario: Negativtest: Suche nach Patient*innen mittels id + family
    Then Get FHIR resource at "http://fhirserver/Patient/?_id=${data.patient-read-extended-id}&family:contains=Mustermann" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() = 0' with error message 'Es wurden Suchergebnisse gefunden obwohl keine erwartet werden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.patient-read-extended-id}')).count() = 0" with error message 'Der gesuchte Patient ${data.patient-read-id} ist unerwartet im Responsebundle enthalten'

  Scenario: Suche nach Patient*innen anhand des Geburtsdatums
    Then Get FHIR resource at "http://fhirserver/Patient/?birthdate=ge1955-06-20" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(birthDate >= @1955-06-20)" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patienten mit einem zu ignorierenden leeren Suchparameter
    Then Get FHIR resource at "http://fhirserver/Patient/?_id=${data.patient-read-id}&family=" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.where(id.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).count() = 1" with error message 'Der gesuchte Patient ${data.patient-read-id} ist nicht im Responsebundle enthalten'
