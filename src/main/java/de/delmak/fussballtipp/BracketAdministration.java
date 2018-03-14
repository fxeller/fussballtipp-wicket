package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Bracket;
import de.delmak.fussballtipp.persistence.Phase;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.WebMarkupContainer;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.StringValidator;
import org.hibernate.Hibernate;

@AuthorizeInstantiation("ADMIN")
public class BracketAdministration extends BasePage
{

	private Phase phase;

	public final Phase getPhase()
	{
		return phase;
	}

	public final void setPhase(Phase phase)
	{
		this.phase = phase;
	}

	private Bracket bracket = null;

	public final Bracket getBracket()
	{
		return bracket;
	}

	public final void setBracket(Bracket bracket)
	{
		this.bracket = bracket;
	}
	
	public BracketAdministration(final PageParameters parameters)
	{
		StringValue paramPhaseId = parameters.get("phaseid");
		if (paramPhaseId.isEmpty() == false)
		{
			setPhase(Phase.getById(paramPhaseId.toInt()));
		}

		StringValue paramMode = parameters.get("mode");
		if (paramMode.isEmpty() == false)
		{
			setMode(paramMode.toString());
		}
		
		StringValue paramBracketId = parameters.get("bracketid");
		if (paramBracketId.isEmpty() == false)
		{
			setBracket(Bracket.getById(paramBracketId.toInt()));
			
			Hibernate.initialize(getBracket().getBracketTeams());
		}
		else
		if (getMode().equals(WicketApplication.MODE_INSERT))
		{
			setBracket(new Bracket());
		}

		WebMarkupContainer pnlData = new WebMarkupContainer("pnlData");
		pnlData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == true);
		add(pnlData);
		
		pnlData.add(new BookmarkablePageLink("lnkBackToMaster", PhaseAdministration.class));
		
		PageParameters pageParamsInsertData = new PageParameters();
		pageParamsInsertData.set("phaseid", getPhase().getPhaseId());
		pageParamsInsertData.set("mode", WicketApplication.MODE_INSERT);

		pnlData.add(new BookmarkablePageLink("lnkInsertData", BracketAdministration.class, pageParamsInsertData));
		
		ListView rptData = new ListView<Bracket>("rptData", Bracket.getListByPhaseId(getPhase().getPhaseId()))
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Bracket bracket = (Bracket)item.getModelObject();
					
					item.add(new Label("fldBracketname", new PropertyModel(item.getModel(), "bracketname")));
					item.add(new Label("fldDescription", new PropertyModel(item.getModel(), "description")));
					
					PageParameters pageParamsModifyData = new PageParameters();
					pageParamsModifyData.set("phaseid", getPhase().getPhaseId());
					pageParamsModifyData.set("mode", WicketApplication.MODE_MODIFY);
					pageParamsModifyData.set("bracketid", bracket.getBracketId());

					item.add(new BookmarkablePageLink("lnkModifyData", BracketAdministration.class, pageParamsModifyData));

					PageParameters pageParamsDeleteData = new PageParameters();
					pageParamsDeleteData.set("phaseid", getPhase().getPhaseId());
					pageParamsDeleteData.set("mode", WicketApplication.MODE_DELETE);
					pageParamsDeleteData.set("bracketid", bracket.getBracketId());

					item.add(new BookmarkablePageLink("lnkDeleteData", BracketAdministration.class, pageParamsDeleteData));

					PageParameters pageParamsBracketTeams = new PageParameters();
					pageParamsBracketTeams.set("bracketid", bracket.getBracketId());
					
					item.add(new BookmarkablePageLink("lnkBracketTeams", BracketTeamAdministration.class, pageParamsBracketTeams));
				}
			};
		
		pnlData.add(rptData);
		
		Form frmData = new Form("frmData", new Model(getBracket()))
			{

				@Override
				protected void onSubmit()
				{
					if (getBracket() != null)
					{
						if (getMode().equals(WicketApplication.MODE_INSERT) == true)
						{
							getBracket().setPhase(getPhase());
							
							Bracket.insert(getBracket());
						}
						else
						if (getMode().equals(WicketApplication.MODE_MODIFY) == true)
						{
							getBracket().setPhase(getPhase());
							
							Bracket.modify(getBracket());
						}
						else
						if (getMode().equals(WicketApplication.MODE_DELETE) == true)
						{
							getBracket().getBracketTeams().clear();
							
							Bracket.delete(getBracket());
						}
						
						PageParameters pageParamsSubmitData = new PageParameters();
						pageParamsSubmitData.set("phaseid", getPhase().getPhaseId());
						
						setResponsePage(BracketAdministration.class, pageParamsSubmitData);
					}
				}		
			};

		frmData.setVisible(getMode().equals(WicketApplication.MODE_BROWSE) == false);
		add(frmData);
		
		String headerText = "";
		
		switch (getMode())
		{
			case WicketApplication.MODE_INSERT: headerText = "Neuanlage"; break;
			case WicketApplication.MODE_MODIFY: headerText = "Änderung"; break;
			case WicketApplication.MODE_DELETE: headerText = "Löschung"; break;
		}
		
		Label lblDataformHeader = new Label("lblDataformHeader", new Model(headerText));
		frmData.add(lblDataformHeader);
		
		TextField txtBracketname = new TextField("txtBracketname", new PropertyModel(getBracket(), "bracketname"));
		txtBracketname.setRequired(true);
		txtBracketname.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true);
		txtBracketname.add(new StringValidator(0, 20));
		frmData.add(txtBracketname);
				
		TextField txtDescription = new TextField("txtDescription", new PropertyModel(getBracket(), "description"));
		txtDescription.setRequired(true);
		txtDescription.setEnabled(getMode().equals(WicketApplication.MODE_INSERT) == true || getMode().equals(WicketApplication.MODE_MODIFY) == true);
		txtDescription.add(new StringValidator(0, 50));
		frmData.add(txtDescription);

		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
